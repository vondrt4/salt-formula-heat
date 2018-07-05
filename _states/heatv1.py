# Import Python libs
from __future__ import absolute_import, print_function, unicode_literals
import logging
import time

LOG = logging.getLogger(__name__)


def __virtual__():
    return 'heatv1'


def _heat_call(fname, *args, **kwargs):
    return __salt__['heatv1.{}'.format(fname)](*args, **kwargs)


def _poll_for_complete(stack_name, cloud_name=None, action=None,
                       poll_period=5, timeout=60):
    if action:
        stop_status = ('{0}_FAILED'.format(action), '{0}_COMPLETE'.format(action))
        stop_check = lambda a: a in stop_status
    else:
        stop_check = lambda a: a.endswith('_COMPLETE') or a.endswith('_FAILED')
    timeout_sec = timeout * 60
    msg_template = '\n Stack %(name)s %(status)s \n'
    while True:
        stack = _heat_call('stack_show',
                           name=stack_name,
                           cloud_name=cloud_name)
        if not stack["result"]:
            raise Exception("request for stack failed")

        stack = stack["body"]["stack"]
        stack_status = stack["stack_status"]
        msg = msg_template % dict(
            name=stack_name, status=stack_status)
        if stop_check(stack_status):
            return stack_status, msg

        time.sleep(poll_period)
        timeout_sec -= poll_period
        if timeout_sec <= 0:
            stack_status = '{0}_FAILED'.format(action)
            msg = 'Timeout expired'
            return stack_status, msg


def stack_present(name, cloud_name, template=None,
                  environment=None, params=None, poll=5, rollback=False,
                  timeout=60, profile=None, **connection_args):
    LOG.debug('Deployed with(' +
              '{0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8} {9})'
              .format(name, cloud_name, template, environment, params,
                      poll, rollback, timeout, profile, connection_args))
    ret = {'name': None,
           'comment': '',
           'changes': {},
           'result': True}

    if not name:
        ret['result'] = False
        ret['comment'] = 'Name is not valid'
        return ret

    ret['name'] = name,

    existing_stack = _heat_call('stack_show', name=name,
                                cloud_name=cloud_name)

    if existing_stack['result']:
        _heat_call('stack_update', name=name,
                   template=template,
                   cloud_name=cloud_name,
                   environment=environment,
                   parameters=params,
                   disable_rollback=not rollback,
                   timeout=timeout)
        ret['changes']['comment'] = 'Updated stack'
        status, res = _poll_for_complete(stack_name=name,
                                         cloud_name=cloud_name,
                                         action="UPDATE", timeout=timeout)
        ret["result"] = status == "UPDATE_COMPLETE"
        ret['comment'] = res
    else:
        _heat_call('stack_create',
                   name=name,
                   template=template,
                   cloud_name=cloud_name,
                   environment=environment,
                   parameters=params,
                   disable_rollback=not rollback,
                   timeout=timeout)
        status, res = _poll_for_complete(stack_name=name,
                                         cloud_name=cloud_name,
                                         action="CREATE", timeout=timeout)
        ret["result"] = status == "CREATE_COMPLETE"
        ret['comment'] = res
    ret['changes']['stack_name'] = name
    return ret


def stack_absent(name, cloud_name, poll=5, timeout=60):
    LOG.debug('Absent with(' +
              '{0}, {1}, {2})'.format(name, poll, cloud_name))
    ret = {'name': None,
           'comment': '',
           'changes': {},
           'result': True}
    if not name:
        ret['result'] = False
        ret['comment'] = 'Name is not valid'
        return ret

    ret['name'] = name,

    existing_stack = _heat_call('stack_show',
                                name=name, cloud_name=cloud_name)

    if not existing_stack['result']:
        ret['result'] = True
        ret['comment'] = 'Stack does not exist'
        return ret

    _heat_call('stack_delete', name=name, cloud_name=cloud_name)
    status, comment = _poll_for_complete(stack_name=name,
                                         cloud_name=cloud_name,
                                         action="DELETE", timeout=timeout)
    ret['result'] = status == "DELETE_COMPLETE"
    ret['comment'] = comment
    ret['changes']['stack_name'] = name
    return ret
