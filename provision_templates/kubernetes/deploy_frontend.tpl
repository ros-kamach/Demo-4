apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: eschool-frontend-deployment
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: eschool-frontend
    spec:
      containers:
        - name: eschool-frontend
          image: us.gcr.io/${gcp_project_id}/conteiner_frontend:v1.0
          imagePullPolicy: Always
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 90
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 90
            periodSeconds: 10
          ports:
            - containerPort: 80
      imagePullSecrets:
        - name: gcr-json-key