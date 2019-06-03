---
- hosts: localhost
  become: true
  tasks:
    - name: Build Frontend Docker image from Dockerfile
      docker_image:
        name: conteiner_frontend
        tag: v1.0
        path: /tmp/templates/frontend
        dockerfile: Dockerfile_frontend
        state: present  

    - name: Tag and Push Image into GCR
      docker_image:
        name: conteiner_frontend
        repository: us.gcr.io/${gcp_project_id}/conteiner_frontend
        tag: v1.0
        push: yes
...