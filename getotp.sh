#!/bin/bash  

export PATH="/usr/bin:$PATH"

output=''
query=$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')
  
# 遍历 ~/.totp 目录下所有以 .key 结尾的文件  
for key_file in ~/.totp/*.key; do  

    if [[ -f "$key_file" ]]; then  

        # 根据文件名筛K
        filename=$(basename "$key_file")
        search_filename=$(printf '%s' "$filename" | tr '[:upper:]' '[:lower:]')
        if [[ "$search_filename" != *"$query"* ]]; then
            continue
        fi

        # 解密totp秘钥
        totp_secret=$(sshenc -s ~/.ssh/id_rsa < "$key_file")  
          
        # 获取一次性密码 
        otp=$(oathtool --totp --base32 "$totp_secret")  
          
		if [[ -z "$output" ]]; then
			output='{"rerun": 1, "items":['
		else
			output+=','
			if [[ "$3" == "--newline" ]]; then
				output+="\n"
			fi
		fi

		item="{\"type\":\"default\", \"icon\": {\"path\": \"icon.png\"}, \"arg\": \"$otp\", \"subtitle\": \"${filename}\", \"title\": \"$otp\"}"
    	output+=$item
    fi  
done
  

if [[ -z "$output" ]]; then
	output='{"rerun": 1, "items":[]}'
else
	output+=']}'
fi

echo $output
 