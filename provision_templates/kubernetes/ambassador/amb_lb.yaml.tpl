---
apiVersion: v1
kind: Service
metadata:
  name: ambassador
spec:
  type: LoadBalancer
  loadBalancerIP: ${lb_global_ip}
  externalTrafficPolicy: Local
  ports:
   - port: 80
     targetPort: 8080
   - port: 8877
     targetPort: 8877  
  selector:
    service: ambassador