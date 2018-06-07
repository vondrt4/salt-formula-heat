from yaml import safe_load
import json
import common
try:
    from urllib.parse import urlencode
except ImportError:
    from urllib import urlencode

HEAT_ROOT = "/srv/heat/env"

TEMPLATE_PATH = "template"
ENV_PATH = "env"


def _read_env_file(name):
    path = "/".join([
        HEAT_ROOT,
        ENV_PATH,
        name])

    return _read_file(path)


def _read_template_file(name):
    path = "/".join([
        HEAT_ROOT,
        TEMPLATE_PATH,
        name])

    return _read_file(path)


def _read_file(full_path):
    with open(full_path, 'r') as f:
        data = safe_load(f)
        return json.dumps(data, default=str)


def _read_additional_file(path):
    full_path = "/".join([
        HEAT_ROOT,
        path])
    with open(full_path) as f:
        return str(f.read())


@common.send("get")
def stack_list(**kwargs):
    url = "/stacks?{}".format(urlencode(kwargs))
    return url, {}


@common.get_by_name_or_uuid(stack_list, 'stacks')
@common.send("get")
def stack_show(stack_id, **kwargs):
    stack_name = kwargs.get("name")
    url = "/stacks/{stack_name}/{stack_id}".format(
        stack_name=stack_name, stack_id=stack_id)
    return url, {}


@common.get_by_name_or_uuid(stack_list, 'stacks')
@common.send("delete")
def stack_delete(stack_id, **kwargs):
    stack_name = kwargs.get("name")
    url = "/stacks/{stack_name}/{stack_id}".format(stack_name=stack_name,
                                                   stack_id=stack_id)
    return url, {}


@common.send("post")
def stack_create(name, template=None, environment=None, environment_files=None,
                 files=None, parameters=None, template_url=None,
                 timeout_mins=5, disable_rollback=True, **kwargs):
    url = "/stacks"
    request = {'stack_name': name,
               'timeout_mins': timeout_mins,
               'disable_rollback': disable_rollback}
    if environment:
        request["environment"] = environment
    file_items = {}
    if environment_files:
        env_names = []
        env_files = {}
        for f_name in environment_files:
            data = _read_env_file(f_name)
            env_files[f_name] = data
            env_names.append(f_name)
        file_items.update(env_files)
        request["environment_files"] = env_names
    if files:
        for f_name, path in files.items():
            file_items.update((f_name, _read_additional_file(path)))
    if file_items:
        request["files"] = file_items
    if parameters:
        request["parameters"] = parameters
    if template:
        template_file = _read_template_file(template)
        request["template"] = template_file
    if template_url:
        request["template_url"] = template_url
    # Validate the template and get back the params.

    return url, {"json": request}


@common.get_by_name_or_uuid(stack_list, 'stacks')
@common.send("put")
def stack_update(stack_id, template=None, environment=None,
                 environment_files=None, files=None, parameters=None,
                 template_url=None, timeout_mins=5, disable_rollback=True,
                 clear_parameters=None, **kwargs):
    stack_name = kwargs.get("name")
    url = "/stacks/{stack_name}/{stack_id}".format(
        stack_name=stack_name, stack_id=stack_id
    )
    request = {'stack_name': stack_name,
               'timeout_mins': timeout_mins,
               'disable_rollback': disable_rollback}
    if environment:
        request["environment"] = environment
    file_items = {}
    if environment_files:
        env_names = []
        env_files = {}
        for f_name in environment_files:
            data = _read_env_file(f_name)
            env_files[f_name] = data
            env_names.append(f_name)
        file_items.update(env_files)
        request["environment_files"] = env_names
    if files:
        for f_name, path in files.items():
            file_items.update((f_name, _read_additional_file(path)))
    if file_items:
        request["files"] = file_items
    if parameters:
        request["parameters"] = parameters
    if template:
        template_file = _read_template_file(template)
        request["template"] = template_file
    if template_url:
        request["template_url"] = template_url
    if clear_parameters:
        request["clear_parameters"] = clear_parameters
    return url, {"json": request}
