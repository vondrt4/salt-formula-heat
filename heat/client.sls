{%- from "heat/map.jinja" import client with context %}
{%- if client.enabled %}

include:
- git

heat_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

heat_client_home:
  file.directory:
  - name: /srv/heat


{%- for project_name, project in client.template.iteritems() %}

{%- if project.source.engine == 'git' %}

{{ project.source.address }}:
  git.latest:
  - target: /srv/heat/env/{{ project.domain }}/{{ project_name }}
  - rev: {{ project.source.revision }}
  - require:
    - pkg: git_packages
    - file: /srv/heat

{%- endif %}

{%- endfor %}

{%- endif %}