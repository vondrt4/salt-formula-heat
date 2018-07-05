"""
Module for handling Heat stacks.

:depends:   - os_client_config
:configuration: This module is not usable until the following are specified
"""

try:
    import os_client_config
    REQUIREMENTS_MET = True
except ImportError:
    REQUIREMENTS_MET = False

import os
import sys

# i failed to load module witjout this
# seems bugs in salt or it is only me
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

import stack

stack_create = stack.stack_create
stack_delete = stack.stack_delete
stack_list = stack.stack_list
stack_show = stack.stack_show
stack_update = stack.stack_update

__all__ = ('stack_create', 'stack_list', 'stack_delete', 'stack_show',
           'stack_update')


def __virtual__():
    if REQUIREMENTS_MET:
        return 'heatv1'
    else:
        return False, ("The heat execution module cannot be loaded: "
                       "os_client_config is not available.")
