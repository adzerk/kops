DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
RELEASE_NAME=ingress-nginx
NAMESPACE=ingress-nginx

NAMESPACE_VAR="
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
  labels:
    app.kubernetes.io/name: $RELEASE_NAME
    app.kubernetes.io/instance: $RELEASE_NAME
    k8s-addon: ingress-nginx.addons.k8s.io
"

SETTINGS="
controller:
  labels:
    k8s-addon: ingress-nginx.addons.k8s.io
  service:
    type: NodePort
    nodePorts:
      http: 30080
      https: 30443
  admissionWebhooks:
    enabled: false
  ingressClassResource:
    default: true
  publishService:
    enabled: false
  config:
    enable-real-ip: true
"

echo "Adding ingress-nginx to chart repositories"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

echo "Generating manifest"
OUTPUT_FILE="${DIR}/v2.0.0.yaml"
echo "$NAMESPACE_VAR" > "$OUTPUT_FILE"
echo "$SETTINGS" | helm template $RELEASE_NAME ingress-nginx/ingress-nginx --namespace $NAMESPACE --values - | grep -v -i "helm" | tee -a "$OUTPUT_FILE"

echo "Done"
