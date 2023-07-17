kubectl create secret generic prod-db-secret --from-literal=username=produser --from-literal=password=Y4nys7f11

 kubectl describe pods -n postgresql
Name:             postgresql-0
Namespace:        postgresql
Priority:         0
Service Account:  default
Node:             minion/192.168.72.201
Start Time:       Wed, 12 Jul 2023 03:53:31 +0000
Labels:           app.kubernetes.io/component=primary
                  app.kubernetes.io/instance=postgresql
                  app.kubernetes.io/managed-by=Helm
                  app.kubernetes.io/name=postgresql
                  controller-revision-hash=postgresql-76fc9ff656
                  helm.sh/chart=postgresql-12.6.5
                  statefulset.kubernetes.io/pod-name=postgresql-0
Annotations:      <none>
Status:           Pending
IP:               10.217.0.176
IPs:
  IP:           10.217.0.176
Controlled By:  StatefulSet/postgresql
Containers:
  postgresql:
    Container ID:   cri-o://b94b4e1222092b010dee02aa026df2f87e28f56dc4ca17be71da22c29dc6af78
    Image:          docker.io/bitnami/postgresql:15.3.0-debian-11-r17
    Image ID:       docker.io/bitnami/postgresql@sha256:1d4fa6a4ce3ddb75ec40503f8e242978a6986d4f0f075f74fca21ff125fc1d07
    Port:           5432/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 12 Jul 2023 03:53:45 +0000
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:      250m
      memory:   256Mi
    Liveness:   exec [/bin/sh -c exec pg_isready -U "postgres" -d "dbname=keycloack" -h 127.0.0.1 -p 5432] delay=30s timeout=5s period=10s #success=1 #failure=6
    Readiness:  exec [/bin/sh -c -e exec pg_isready -U "postgres" -d "dbname=keycloack" -h 127.0.0.1 -p 5432
[ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]
] delay=5s timeout=5s period=10s #success=1 #failure=6
    Environment:
      BITNAMI_DEBUG:                        false
      POSTGRESQL_PORT_NUMBER:               5432
      POSTGRESQL_VOLUME_DIR:                /bitnami/postgresql
      PGDATA:                               /bitnami/postgresql/data
      POSTGRES_PASSWORD:                    <set to the key 'postgres-password' in secret 'postgresql'>  Optional: false
      POSTGRES_DATABASE:                    keycloack
      POSTGRESQL_ENABLE_LDAP:               no
      POSTGRESQL_ENABLE_TLS:                no
      POSTGRESQL_LOG_HOSTNAME:              false
      POSTGRESQL_LOG_CONNECTIONS:           false
      POSTGRESQL_LOG_DISCONNECTIONS:        false
      POSTGRESQL_PGAUDIT_LOG_CATALOG:       off
      POSTGRESQL_CLIENT_MIN_MESSAGES:       error
      POSTGRESQL_SHARED_PRELOAD_LIBRARIES:  pgaudit
    Mounts:
      /bitnami/postgresql from data (rw)
      /dev/shm from dshm (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6x624 (ro)
  metrics:
    Container ID:
    Image:          docker.io/bitnami/postgres-exporter:0.13.1-debian-11-r0
    Image ID:
    Port:           9187/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       CreateContainerConfigError
    Ready:          False
    Restart Count:  0
    Liveness:       http-get http://:http-metrics/ delay=5s timeout=5s period=10s #success=1 #failure=6
    Readiness:      http-get http://:http-metrics/ delay=5s timeout=5s period=10s #success=1 #failure=6
    Environment:
      DATA_SOURCE_URI:   127.0.0.1:5432/keycloack?sslmode=disable
      DATA_SOURCE_PASS:  <set to the key 'password' in secret 'postgresql'>  Optional: false
      DATA_SOURCE_USER:  postgres
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6x624 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  data-postgresql-0
    ReadOnly:   false
  dshm:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     Memory
    SizeLimit:  <unset>
  kube-api-access-6x624:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                     From               Message
  ----     ------     ----                    ----               -------
  Normal   Scheduled  4m54s                   default-scheduler  Successfully assigned postgresql/postgresql-0 to minion
  Normal   Pulling    4m53s                   kubelet            Pulling image "docker.io/bitnami/postgresql:15.3.0-debian-11-r17"
  Normal   Pulled     4m40s                   kubelet            Successfully pulled image "docker.io/bitnami/postgresql:15.3.0-debian-11-r17" in 13.851214409s (13.851239413s including waiting)
  Normal   Created    4m40s                   kubelet            Created container postgresql
  Normal   Started    4m40s                   kubelet            Started container postgresql
  Normal   Pulling    4m40s                   kubelet            Pulling image "docker.io/bitnami/postgres-exporter:0.13.1-debian-11-r0"
  Normal   Pulled     4m32s                   kubelet            Successfully pulled image "docker.io/bitnami/postgres-exporter:0.13.1-debian-11-r0" in 7.820598638s (7.820630764s including waiting)
  Warning  Failed     3m12s (x10 over 4m32s)  kubelet            Error: couldn't find key password in Secret postgresql/postgresql
  Normal   Pulled     3m12s (x9 over 4m31s)   kubelet            Container image "docker.io/bitnami/postgres-exporter:0.13.1-debian-11-r0" already present on machine
[root@minion ~]#