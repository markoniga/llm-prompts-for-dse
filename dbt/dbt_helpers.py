import json
import subprocess
import os
import sys
import re

COMPLETION_PING = '''&& osascript -e \'display notification "✅ DBT script completed" with title "DBT Done!"\' \
    || case \
        $? in \
            1) osascript -e \'display notification "⚠️ DBT script completed with model error !" with title "DBT Model Error!"\' && exit 1;; \
            2) osascript -e \'display notification "‼️ DBT script failed or was killed ‼️" with title "DBT Failed!"\' && exit 2;; \
        esac
'''


def _remove_orphaned_containers():
    subprocess.run('docker compose down --remove-orphans',
                   shell=True, capture_output=True)


def _model_path_check(ls_args):
    if not ls_args:
        print('No models found in select statement. Exiting the run.')
        sys.exit(0)
    if '+' in ls_args or '.' in ls_args:
        print('Multiple models found in select statement. Checking number of models triggered...')
        return True
    return False


def _run_models_user_input(models_to_run, num_of_models_threshold):
    num_of_models = len(models_to_run)
    if num_of_models > num_of_models_threshold:
        msg = (f'\nYour model selection will build {num_of_models} models.\n'
               'Do you wish to continue or abort and use the rebuild script to speed up your work instead?\n'
               'To continue - please answer with y/n. (y = continue)\n')
        should_we_run_this = input(msg)
        if should_we_run_this != 'y':
            print('Exiting the run.')
            sys.exit(0)
        else:
            print('Running your original statement...')


def _handle_missing_deps(project_dir, profiles_dir):
    dbt_modules = f'{os.getcwd()}/projects/{project_dir}/dbt_modules'
    if not os.path.isdir(dbt_modules) or len(os.listdir(dbt_modules)) == 0:
        subprocess.run(f'docker compose run dbt deps --project-dir={project_dir} --profiles-dir={profiles_dir}', shell=True)

def _get_model_list(select, project_dir, profiles_dir, dbt_vars):
    print('\nGrabbing list of models we\'re building..\n')
    select_ = f'--select {select}' if select != '' else ''
    model_proc = subprocess.run(f'docker compose run dbt --quiet ls {select_} --project-dir={project_dir} --profiles-dir={profiles_dir} --vars={dbt_vars} --target=development --output json --output-keys unique_id', shell=True, capture_output=True, text=True)
    if model_proc.returncode != 0:
        print(model_proc.stdout)
        sys.exit(model_proc.returncode)
    models = model_proc.stdout.rstrip().split('\n')
    return [json.loads(node).get('unique_id') for node in models]

def _get_manifest(target_path, compile=False, project_dir=None, profiles_dir=None, dbt_vars=None):
    if compile:
        print('\nCompiling dbt project to ensure your manifest file is up-to-date..\n')
        subprocess.run(f'docker compose run dbt parse --write-manifest --project-dir={project_dir} --profiles-dir={profiles_dir} --vars={dbt_vars} --target=development', shell=True)
    with open(f'{target_path}/manifest.json') as f:
        manifest = json.load(f)
    return manifest

def rebuild(select, project_dir, profiles_dir, target_path, dbt_vars):
    select_stmt = ' '.join(select)
    models_to_run = _get_model_list(select_stmt, project_dir, profiles_dir, dbt_vars)
    manifest = _get_manifest(target_path)
    parents = []
    for node_key in models_to_run:
        parent = _get_next_materialized_parent(manifest, node_key)
        test_dependencies = _get_downstream_test_dependencies(manifest, node_key)
        for parent_node in parent:
            # don't want to rebuild for any nodes we're building in the current run
            if parent_node not in models_to_run:
                parents.append(parent_node)
        for test_dependency in test_dependencies:
            if test_dependency not in models_to_run:
                parents.append(test_dependency)

    rebuild_nodes = set([_get_node_schema_table(manifest, node) for node in parents])
    print(f"Rebuilding: {rebuild_nodes}")
    if rebuild_nodes:
        _run_rebuild(rebuild_nodes, profiles_dir, project_dir, dbt_vars)

def _get_node_schema_table(manifest, dbt_node):
    model_type = manifest['nodes'][dbt_node]['config']['materialized']
    if model_type == 'snapshot':
        model_path = manifest['nodes'][dbt_node]['path']
        model_folder = model_path.split('/')[-2]
        schema = f'{model_folder}_{model_type}s'
    else:
        schema = manifest['nodes'][dbt_node]['config']['schema']
    table = manifest['nodes'][dbt_node]['name']
    return f'{schema}.{table}'

def _get_node_name(manifest, dbt_node):
    return manifest['nodes'][dbt_node]['name']

def set_dbt_paths(project):
    project_dir = os.path.abspath('projects/')
    os.environ['DBT_LOGS'] = os.path.join(project_dir, project, 'logs')
    os.environ['DBT_TARGET'] = os.path.join(project_dir, project, 'target')
    os.environ['DBT_MODULES'] = os.path.join(project_dir, project, 'dbt_modules')

def _run_rebuild(schema_tables, profiles_dir, project_dir, dbt_vars, row_limit=None):
    DEV_SQL_SCHEMA_PREFIX = os.environ['DEV_SQL_SCHEMA_PREFIX']
    DBT_DEV_SCHEMA = f'dev_{DEV_SQL_SCHEMA_PREFIX}'
    print(f'\nBuilding views of {len(schema_tables)} necessary upstream models..\n')

    if row_limit:
        run_operation_args = f'{{dev_schema: {DBT_DEV_SCHEMA}, prod_schema_tables: {schema_tables}, row_limit: {row_limit}}}'
    else:
        run_operation_args = f'{{dev_schema: {DBT_DEV_SCHEMA}, prod_schema_tables: {schema_tables}}}'
    subprocess.run(f'docker compose run dbt run-operation create_views_from_prod_tables --profiles-dir {profiles_dir} --project-dir {project_dir} --vars {dbt_vars} --args \'{run_operation_args}\'', shell=True)

def _get_next_materalized_child(manifest, dbt_node, materialized_types=['table', 'incremental', 'view', 'test', 'seed', 'snapshot']):
    child_nodes = []
    for child_node_key, child_node_value in manifest['nodes'].items():
        if dbt_node in child_node_value['depends_on']['nodes']:
            child_node_config = manifest['nodes'][child_node_key]
            child_node_mat = child_node_config['config']['materialized']
            if child_node_mat in materialized_types:
                child_nodes.append(child_node_key)
            elif child_node_mat == 'ephemeral':
                # child_node_key is not materialized, stepping down 1 layer
                child_child_node = _get_next_materalized_child(manifest, child_node_key, materialized_types)
                if child_child_node != []:
                    child_nodes.extend(child_child_node)
    return child_nodes

def _get_next_materialized_parent(manifest, dbt_node, materialized_types=['table', 'incremental', 'view', 'test', 'seed', 'snapshot']):
    parent_nodes = []
    if not dbt_node.startswith('source'):
        for parent_node in manifest['nodes'][dbt_node].get('depends_on', {}).get('nodes', []):
            if not parent_node.startswith('source'):
                parent_node_meta = manifest['nodes'][parent_node]
                parent_node_mat = parent_node_meta['config']['materialized']

                if parent_node_mat in materialized_types:
                    parent_nodes.append(parent_node)

                elif parent_node_mat == 'ephemeral':
                    # parent_node is not materialized, stepping up 1 layer
                    parent_parent_node = _get_next_materialized_parent(manifest, parent_node, materialized_types)
                    if parent_parent_node != []:
                        parent_nodes.extend(parent_parent_node)
    return parent_nodes

def _get_downstream_test_dependencies(manifest, dbt_node):
    downstream_tests = _get_next_materalized_child(manifest, dbt_node, materialized_types=['test'])
    upstream_test_dependencies = []
    for downstream_test in downstream_tests:
        test_parents = _get_next_materialized_parent(manifest, downstream_test)
        upstream_test_dependencies.extend(test_parents)
    return list(set(upstream_test_dependencies))

def _get_succesful_models_from_previous_run(target_path, manifest):
    with open(f'{target_path}/run_results.json') as f:
        run_results = json.load(f)
    succesful_models = [
        _get_node_name(manifest, model['unique_id']) for model in run_results['results'] 
        if model['status'] == 'success'
        ]
    return succesful_models


def _get_failed_models_from_previous_run(target_path, manifest):
    with open(f'{target_path}/run_results.json') as f:
        run_results = json.load(f)
    failed_models_unique_id = [
        model['unique_id'] for model in run_results['results'] 
        if model['status'] in ('error', 'skipped')
        ]
    return failed_models_unique_id


def _get_list_of_missing_schema_configs(node_diffs, manifest):
    missing_schema_nodes = []
    for node in node_diffs:
        node_config = manifest['nodes'].get(node)
        if node_config.get('resource_type', None) in ['model', 'seed'] and node_config.get('config').get('materialized') != 'ephemeral':
            node_schema = node_config.get('config').get('schema')
            if node_schema == 'dbt_prod' or node_schema == None:
                missing_schema_nodes.append(node)
    return missing_schema_nodes

def _drop_existing_views(tables, profiles_dir, project_dir, dbt_vars):
    print('\nChecking if we need to drop existing views from previous runs..\n')
    DEV_SQL_SCHEMA_PREFIX = os.environ['DEV_SQL_SCHEMA_PREFIX']
    DBT_DEV_SCHEMA = f'dev_{DEV_SQL_SCHEMA_PREFIX}'
    run_operation_args = f'{{dev_schema: {DBT_DEV_SCHEMA}, tables: {tables}}}'
    if tables:
        subprocess.run(f'docker compose run dbt run-operation drop_existing_views_in_dev_schema --profiles-dir {profiles_dir} --project-dir {project_dir} --vars {dbt_vars} --args \'{run_operation_args}\'', shell=True)


def _get_incremental_models(nodes, manifest) -> list:
    incremental_nodes = []
    for node in nodes:
        if manifest['nodes'][node]['config']['materialized'] == 'incremental':
            incremental_nodes.append(node)
    return set(incremental_nodes)
