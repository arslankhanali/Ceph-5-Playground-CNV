radosgw-admin user create --uid='user1' --display-name='First User' --access-key='S3user1' --secret-key='S3user1key'
radosgw-admin subuser create --uid='user1' --subuser='user1:swift' --secret-key='Swiftuser1key' --access=full

#########################################################
#  Lets test with SWIFT CLI
# On Cluster 1
# Install swift cli
pip3 install python-swiftclient

# Create a user
radosgw-admin user create --uid='user1' --display-name='First User' --access-key='S3user1' --secret-key='S3user1key'
radosgw-admin subuser create --uid='user1' --subuser='user1:swift' --secret-key='Swiftuser1key' --access=full

# Set variables
export IP="localhost"
export PORT="80"
export SWIFT_AUTH_URL="http://$IP:$PORT/auth/1.0"
export SWIFT_USER="user1:swift"
export SWIFT_KEY="Swiftuser1key"
export R_BUCKET_NAME="replication_bucket"
export EC_BUCKET_NAME="ec_bucket"
export DUMMY_NAME="dummy_file"

# Create 300Mb dumy object
base64 /dev/urandom | head -c 30000000 > $DUMMY_NAME

# Check conenction by listing all buckets to this user
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" list

# Create Replication bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" post -H "X-Storage-Policy: r-placement" $R_BUCKET_NAME
# Create EC bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" post -H "X-Storage-Policy: ec-placement" $EC_BUCKET_NAME

# Upload to Rep bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" upload $R_BUCKET_NAME $DUMMY_NAME
# Upload to EC bucket
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" upload $EC_BUCKET_NAME $DUMMY_NAME

# List objects in buckets
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" list $R_BUCKET_NAME
swift -A $SWIFT_AUTH_URL -U $SWIFT_USER -K "$SWIFT_KEY" list $EC_BUCKET_NAME

#########################################################
# Explanation
ceph df

--- RAW STORAGE ---
CLASS    SIZE   AVAIL     USED  RAW USED  %RAW USED
hdd    60 GiB  57 GiB  3.1 GiB   3.1 GiB       5.18
TOTAL  60 GiB  57 GiB  3.1 GiB   3.1 GiB       5.18
 
--- POOLS ---
POOL                     ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr                      1    1  449 KiB        2  1.3 MiB      0     18 GiB
east.rgw.otp              6   32      0 B        0      0 B      0     18 GiB
east.rgw.log              7   32   51 KiB      665  3.8 MiB      0     18 GiB
.rgw.root                 8   32  8.5 KiB       19  216 KiB      0     18 GiB
default.rgw.log           9   32    182 B        2   24 KiB      0     18 GiB
default.rgw.control      10   32      0 B        8      0 B      0     18 GiB
default.rgw.meta         11   32      0 B        0      0 B      0     18 GiB
east.rgw.control         12   32      0 B        8      0 B      0     18 GiB
east.rgw.meta            13   32   10 KiB       20  211 KiB      0     18 GiB
east.rgw.buckets.index   14   32   11 KiB       77   33 KiB      0     18 GiB
east.rgw.buckets.data    15  256  206 MiB       61  618 MiB   1.12     18 GiB
east.rgw.buckets.non-ec  16   32  4.5 KiB        0   13 KiB      0     18 GiB
ecpool                   17   32   29 MiB        9   43 MiB   0.08     36 GiB
rpool                    21   32   29 MiB        8   86 MiB   0.16     18 GiB

# Explanation
Total available Storage = 57 GiB
Since most pools are replication(3x) = Their usable storage is 57/3 ~ 18Gb

Notice because ecpool is using [2,1] Erasure coding profile it has more available storage
(2/(2+1))*57 ~ 36Gb

#########################################################
# Find out on which OSDs was the objects saved
# Check which OSD is on what host
# Since crush-failure-domain=host, Object should not be on OSDs which are on the same host
ceph osd tree
ceph osd map $rpool $DUMMY_NAME -f json-pretty
ceph osd map $ecpool $DUMMY_NAME -f json-pretty


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