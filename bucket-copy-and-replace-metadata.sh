# Description: S3バケット間でファイルをコピーし、拡張子がPDFの場合はメタデータを上書きします。
BUCKET="" # コピー元のバケット名
PREFIX="" # コピー元のプレフィックス
DEST_BUCKET="" # コピー先のバケット名

# すべてのファイルを取得して1行ずつ処理
aws s3api list-objects-v2 --bucket $BUCKET --prefix $PREFIX \
  --query "Contents[].Key" --output text | tr '\t' '\n' | \
  while read -r KEY; do
    if [ ! -z "$KEY" ]; then
      echo "Copying $KEY..."
      
      # ファイルの拡張子がPDFの場合はメタデータを上書き
      if [[ "$KEY" == *.pdf ]]; then
        aws s3api copy-object \
          --bucket $DEST_BUCKET \
          --copy-source "$BUCKET/$KEY" \
          --key "$KEY" \
          --content-type "application/pdf" \
          --metadata-directive REPLACE
      else
        aws s3api copy-object \
          --bucket $DEST_BUCKET \
          --copy-source "$BUCKET/$KEY" \
          --key "$KEY"
      fi
    fi
  done
