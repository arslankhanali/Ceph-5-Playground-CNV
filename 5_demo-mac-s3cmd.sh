radosgw-admin user create --uid='user1' --display-name='First User' --access-key='S3user1' --secret-key='S3user1key'
radosgw-admin subuser create --uid='user1' --subuser='user1:swift' --secret-key='Swiftuser1key' --access=full

# #############################################
#  s3cmd
# #############################################
export S3_ACCESS_KEY="S3user1"
export S3_SECRET_KEY="S3user1key"

# cluster1
export IP="localhost"
export PORT="8888"
export S3_URL="http://$IP:$PORT"
export HOST_BASE="$IP:$PORT"

# cluster 2
export PORT1="9999"
export S3_URL="http://$IP:$PORT1"
export HOST_BASE="$IP:$PORT1"

export BUCKET_NAME="cluster1-bucket"
export DUMMY_FILE_NAME="cluster-1-dummy_file"
export file_size="5"
export num_files=5

echo $S3_ACCESS_KEY
echo $S3_SECRET_KEY

# Configure s3cmd
# s3cmd --configure
# /Users/arslankhan/.s3cfg

# Use full config from other file 48-1 if you dont want to use --no-ssl with every command
cat > /Users/arslankhan/.s3cfg << EOF
[default]
access_key = $S3_ACCESS_KEY
secret_key = $S3_SECRET_KEY
host_base = $HOST_BASE
check_ssl_certificate = False
check_ssl_hostname = True
ssl_client_cert_file = 
ssl_client_key_file = 
EOF

# Test Confugurations
s3cmd --debug ls --recursive # if using from the file 48-1
s3cmd --debug ls --recursive --no-ssl  # if using above
# s3cmd md 
# s3cmd rb 
# s3cmd ls 
# s3cmd la 
# s3cmd put 
# s3cmd get 
# s3cmd del 
# s3cmd du 
# s3cmd info 

#create dummy objects
#dd if=/dev/zero of=dummy_file-1 bs=1M count=10 #1x10Mb

for ((i=1; i<=$num_files; i++)); do
    dd if=/dev/zero of="${DUMMY_FILE_NAME}-$i" bs=1M count=$file_size
done

# List all Buckets
s3cmd --access_key=$S3_ACCESS_KEY --secret_key=$S3_SECRET_KEY --host=$HOST_BASE ls --no-ssl
s3cmd ls --no-ssl

#create buckets
s3cmd mb s3://$BUCKET_NAME

#upload to bucket
#s3cmd put dummy_file0 s3://$BUCKET_NAME/dummy_file0

for ((i=1; i<=$num_files; i++)); do
    s3cmd put "${DUMMY_FILE_NAME}-$i" s3://$BUCKET_NAME/"${DUMMY_FILE_NAME}-$i"
done

# List objects in Bucket
#s3cmd ls s3://test
s3cmd ls s3://$BUCKET_NAME

s3cmd --host=$HOST_BASE ls s3://$BUCKET_NAME
s3cmd  --host=$HOST_BASE2 ls s3://$BUCKET_NAME

# delete All
s3cmd del s3://$BUCKET_NAME/dummy_file-1

for ((i=1; i<=$num_files; i++)); do
    s3cmd del s3://$BUCKET_NAME/"${DUMMY_FILE_NAME}-$i"
    s3cmd del s3://$BUCKET_NAME2/"${DUMMY_FILE_NAME2}-$i"
done

s3cmd rb s3://$BUCKET_NAME
s3cmd rb s3://$BUCKET_NAME2

rm "${DUMMY_FILE_NAME}"*
rm "${DUMMY_FILE_NAME2}"*

### ### ### ### ### ### ### ### 
###  On 2nd cluster
### ### ### ### ### ### ### ### 

for ((i=1; i<=$num_files; i++)); do
    dd if=/dev/zero of="${DUMMY_FILE_NAME2}-$i" bs=1M count=$file_size
done

# List all Buckets
s3cmd --access_key=$S3_ACCESS_KEY --secret_key=$S3_SECRET_KEY --host=$HOST_BASE2 ls --no-ssl
s3cmd ls --no-ssl

#create buckets
s3cmd --host=$HOST_BASE2  mb s3://$BUCKET_NAME2

#upload to bucket
#s3cmd put dummy_file0 s3://$BUCKET_NAME/dummy_file0

for ((i=1; i<=$num_files; i++)); do
    s3cmd --host=$HOST_BASE2  put "${DUMMY_FILE_NAME2}-$i" s3://$BUCKET_NAME2/"${DUMMY_FILE_NAME2}-$i"
done

# List objects in Bucket
#s3cmd ls s3://test
s3cmd ls s3://$BUCKET_NAME2
s3cmd --access_key=$S3_ACCESS_KEY --secret_key=$S3_SECRET_KEY --host=$HOST_BASE2 ls s3://$BUCKET_NAME2


# #############################################
#  Dummy FILE
# #############################################
# Generate dummy file LINUX
base64 /dev/urandom | head -c 10000000 > dummy_file1.txt
ls -lh | grep dummy_file1.txt

# Generate dummy file MAC
dd if=/dev/zero of=dummy_file1.txt bs=1M count=10

for ((i=1; i<=$num_files; i++)); do
    dd if=/dev/zero of=dummy_file$i bs=1M count=10
done

rm dummy*