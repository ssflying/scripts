#!/usr/bin/env bash
# 功能：Bash + openssl 实现腾讯云官方命令行
#       tccli tccli vpc ModifyAddressTemplateAttribute --AddressTemplateId <id> --Addresses <address>
# 目的：验证下Bash下如何实现接口鉴权 v3的，并给实现给本机出口IP添加服务器添加白名单
# 参考：腾讯云 https://console.cloud.tencent.com/api/explorer（接口列表中搜索 IP地址模板）
# 作者：cqs.pub AT gmail.com

### 全局设定，自行修改
# 请参考个人账号：https://console.cloud.tencent.com/cam/capi
#SecretId=
#SecretKey=
# 请参考可用地域列表: https://cloud.tencent.com/document/product/213/15708
#Region="ap-seoul"
# 请填入需要修改的模块ID：https://console.cloud.tencent.com/vpc/tpl
#AddressTemplateId="ipm-edjd7jks"

if [[ -z "$SecretId" ]] || [[ -z "$SecretKey" ]] || [[ -z "$Region" ]] || [[ -z "$AddressTemplateId" ]] ; then
    echo "请修改脚本，配置SecretId和SecretKey值，以及可用区域和地址模板"
    exit 1
fi

sha256_hash() {
    local a
    a="$@"
    printf "$a" | openssl dgst -binary -sha256
}

sha256_hash_in_hex() {
    local a
    a="$@"
    printf "$a" | openssl dgst -binary -sha256 -hex | awk '{print $NF}'
}

# 加密的key是普通字符串
hex_of_sha256_hmac_with_str_kv () {
    local key data
    key="$1"
    data="$2"
    printf "$data" | openssl dgst -binary -sha256 -hmac "$key" -hex | awk '{print $NF}'
}

# 加密的key是二进制的hex编码字符串
hex_of_sha256_hmac_with_hex_kv () {
    local key data
    key="$1"
    data="$2"
    printf "$data" | openssl dgst -binary -sha256 -mac HMAC -macopt "hexkey:$key" -hex | awk '{print $NF}'
}


# 最简单的方式就是payload作为变量来复用signature，因为一个脚本调用过程
# TIMESTAMP可以认为全局不变的（5min）的有效期
TIMESTAMP=$(date +%s)
UTC_DATE=$(TZ=UTC date -d @$TIMESTAMP +%F)
CredentialScope="$UTC_DATE/vpc/tc3_request"
get_authorization () {
    local PAYLOAD
    PAYLOAD=$1
    # 签名算法参考：https://cloud.tencent.com/document/api/213/30654

    # ************* 步骤 1：拼接规范请求串 *************
    SHA256_PAYLOAD=$(sha256_hash_in_hex "$PAYLOAD")

    CanonicalRequest="POST
/

content-type:application/json
host:vpc.tencentcloudapi.com

content-type;host
$SHA256_PAYLOAD"

    [[ $DEBUG ]] && printf "$CanonicalRequest\n"
    HashedCanonicalRequest=$(sha256_hash_in_hex "$CanonicalRequest")
    [[ $DEBUG ]] && printf "$HashedCanonicalRequest\n"

    # ************* 步骤 2：拼接待签名字符串 *************
    StringToSign="TC3-HMAC-SHA256
$TIMESTAMP
$CredentialScope
$HashedCanonicalRequest"

    # ************* 步骤 3：计算签名 *************
    SecretDate=$(hex_of_sha256_hmac_with_str_kv "TC3${SecretKey}" "$UTC_DATE")
    SecretService=$(hex_of_sha256_hmac_with_hex_kv "$SecretDate" "vpc")
    SecretSigning=$(hex_of_sha256_hmac_with_hex_kv "$SecretService" "tc3_request")

    Signature=$(hex_of_sha256_hmac_with_hex_kv "$SecretSigning" "$StringToSign")
    [[ $DEBUG ]] && printf "$Signature\n"

    # ************* 步骤 4：拼接 Authorization 值 *************
    Authorization="TC3-HMAC-SHA256 Credential=${SecretId}/${CredentialScope}, SignedHeaders=content-type;host, Signature=$Signature"
    printf "$Authorization"
}

# 本机的出口IP
MYIP=$(curl --silent --connect-timeout 10 http://ipinfo.io/ip)

# 查询当前IP组下有多少IP
QUERY_ADDR_PAYLOAD='{ "Filters": [ { "Name": "address-template-id", "Values": [ "'$AddressTemplateId'" ] } ] }'
AUTH_STR=$(get_authorization "$QUERY_ADDR_PAYLOAD")
RESPONSE=$(
curl --silent -H 'Host: vpc.tencentcloudapi.com' \
    -H 'X-TC-Action: DescribeAddressTemplates' \
    -H "X-TC-Timestamp: $TIMESTAMP" \
    -H 'X-TC-Version: 2017-03-12' \
    -H "X-TC-Region: $Region" \
    -H 'X-TC-Language: zh-CN' \
    -H "Authorization: $AUTH_STR" \
    -H 'Content-Type: application/json' \
    -d "$QUERY_ADDR_PAYLOAD" \
    'https://vpc.tencentcloudapi.com/'
)
if ! grep -q "$AddressTemplateId" <<<"$RESPONSE"; then
    echo "请求失败：$RESPONSE"
    exit 1
fi
CURR_IP_ADDR=$(echo "$RESPONSE" | jq --compact-output .Response.AddressTemplateSet[0].AddressSet)
NEW_IP_ADDR="${CURR_IP_ADDR%]},\"$MYIP\"]"
[[ $DEBUG ]] && printf "$NEW_IP_ADDR\n"

# 修改ip参数的请求
MOD_ADDR_PAYLOAD='{"AddressTemplateId":"'$AddressTemplateId'","Addresses":'$NEW_IP_ADDR'}'

## 生成authorization
AUTH_STR=$(get_authorization "$MOD_ADDR_PAYLOAD")
# 实际请求
curl --silent -H 'Host: vpc.tencentcloudapi.com' \
    -H 'X-TC-Action: ModifyAddressTemplateAttribute' \
    -H "X-TC-Timestamp: $TIMESTAMP" \
    -H 'X-TC-Version: 2017-03-12' \
    -H "X-TC-Region: $Region" \
    -H 'X-TC-Language: zh-CN' \
    -H "Authorization: $AUTH_STR" \
    -H 'Content-Type: application/json' \
    -d "$MOD_ADDR_PAYLOAD" \
    'https://vpc.tencentcloudapi.com/'
