---
- hosts: localhost
  become: true
  tasks:
    - name: Build Backend Docker image from Dockerfile
      docker_image:
        name: conteiner_backend
        tag: v1.0
        path: /tmp/templates/backend
        dockerfile: Dockerfile_backend
        state: present

    - name: Tag and Push Image into GCR
      docker_image:
        name: conteiner_backend
        repository: us.gcr.io/${gcp_project_id}/conteiner_backend
        tag: v1.0
        push: yes
...