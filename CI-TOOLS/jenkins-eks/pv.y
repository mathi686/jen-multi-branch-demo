apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv-ebs
  labels:
    env: dev
spec:
  persistentVolumeReclaimPolicy: Delete
  storageClassName: gp2
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  awsElasticBlockStore:
    volumeID: vol-0be77e0ced36f4971
    fsType: ext4  # Specify the filesystem type, e.g., ext4 or xfs

   