FROM zilliz/gptcache:latest

CMD []

RUN apt-get update && \
	apt-get install -y curl && \
	apt-get install -y git && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

RUN git clone https://github.com/PlusLemon/oai-cache-proxy.git /app
WORKDIR /app
RUN git rev-parse --short HEAD
RUN npm install
COPY Dockerfile greeting.md* .env* ./
RUN npm run build

EXPOSE 7860
ENV NODE_ENV=production
ENV GATEKEEPER=proxy_key
USER root

# RUN pip3 install --no-cache-dir sacremoses

RUN echo 'embedding: huggingface' > /app/cache.yml && \
    echo 'embedding_config:' >> /app/cache.yml && \
    echo '    model: uer/albert-base-chinese-cluecorpussmall' >> /app/cache.yml && \
# RUN echo 'embedding: paddlenlp' > /app/cache.yml && \
    echo 'config:' >>  /app/cache.yml && \
    echo '    similarity_threshold: 0.9' >> /app/cache.yml

RUN echo '#!/bin/bash' > /app/startup-script.sh && \
    echo 'gptcache_server -s 0.0.0.0 -f /app/cache.yml &' >> /app/startup-script.sh && \
    echo 'npm start' >> /app/startup-script.sh && \
    chmod +x /app/startup-script.sh

RUN mkdir /.npm && \
    mkdir -p /.local/bin && \
    mkdir -p /.cache/pip && \
    mkdir gptcache_data && \
    chown -R 1000:0 "/.npm" "/.local" "/.cache" "/usr/local" "gptcache_data"

RUN python3 -m pip install --upgrade pip

ENV PATH="/.local/bin:$PATH"

ENTRYPOINT sh -c "/app/startup-script.sh"
