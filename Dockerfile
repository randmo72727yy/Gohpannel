# ---------------------------------------------------------------------------
# مرحله ۱: دانلود باینری رسمی Xray-core (بدون کامپایل، بدون سورس اضافه)
# ---------------------------------------------------------------------------
FROM alpine:3.20 AS fetcher

# نسخه ثابت را build arg قابل override می‌کنیم؛ پیش‌فرض = آخرین ریلیز
ARG XRAY_VERSION=latest

RUN apk add --no-cache curl unzip ca-certificates file

WORKDIR /tmp/xray

RUN set -eux; \
    if [ "$XRAY_VERSION" = "latest" ]; then \
        DL_URL="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip"; \
    else \
        DL_URL="https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip"; \
    fi; \
    echo "Downloading: $DL_URL"; \
    curl -fL --retry 3 "$DL_URL" -o xray.zip; \
    file xray.zip; \
    unzip xray.zip -d /tmp/xray-bin; \
    chmod +x /tmp/xray-bin/xray

# ---------------------------------------------------------------------------
# مرحله ۲: ایمیج نهایی، فقط باینری + اسکریپت شروع (بدون Docker پیچیده، بدون DB)
# ---------------------------------------------------------------------------
FROM alpine:3.20

RUN apk add --no-cache ca-certificates bash

WORKDIR /app

COPY --from=fetcher /tmp/xray-bin/xray /app/xray
COPY entrypoint.sh /app/entrypoint.sh
COPY config.template.json /app/config.template.json

RUN chmod +x /app/entrypoint.sh /app/xray

# پورت ثابتی expose نمی‌کنیم؛ Railway مقدار PORT را خودش تزریق می‌کند
ENTRYPOINT ["/app/entrypoint.sh"]
