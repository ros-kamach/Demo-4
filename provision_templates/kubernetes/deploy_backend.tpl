apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: eschool-backend-deployment
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: eschool-backend
    spec:
      containers:
        - name: eschool-backend
          image: us.gcr.io/${gcp_project_id}/conteiner_backend:v1.0
          imagePullPolicy: Always
          readinessProbe:
            httpGet:
              path: /ui/login
              port: 8080
            initialDelaySeconds: 90
            periodSeconds: 10
          ports:
            - containerPort: 8080
        - name: cloudsql-proxy
          image: gcr.io/cloudsql-docker/gce-proxy:1.11
          command: ["/cloud_sql_proxy", "--dir=/cloudsql",
                    "-instances=${gcp_project_id}:${region}:${sql_instance_name}=tcp:3306",
                    "-credential_file=/secrets/cloudsql/credentials.json"]
          volumeMounts:
            - name: cloudsql-instance-credentials
              mountPath: /secrets/cloudsql
              readOnly: true
            - name: ssl-certs
              mountPath: /etc/ssl/certs
            - name: cloudsql
              mountPath: /cloudsql
      volumes:
        - name: cloudsql-instance-credentials
          secret:
            secretName: cloudsql-instance-credentials
        - name: cloudsql
          emptyDir:
        - name: ssl-certs
          hostPath:
            path: /etc/ssl/certs
      imagePullSecrets:
        - name: gcr-json-key