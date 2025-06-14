FROM alpine:3.16

ENV PHP_INI_DIR /usr/local/etc/php
ENV PHPIZE_DEPS autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"
ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312
ENV PHP_VERSION 7.4.33
ENV PHP_URL="https://www.php.net/distributions/php-7.4.33.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-7.4.33.tar.xz.asc"
ENV PHP_SHA256="924846abf93bc613815c55dd3f5809377813ac62a9ec4eb3778675b82a27b927"

RUN apk add --no-cache ca-certificates curl tar xz openssl
RUN set -eux && mkdir -p "$PHP_INI_DIR/conf.d"
RUN set -eux; \
    \
    apk add --no-cache --virtual .fetch-deps gnupg; \
    \
    mkdir -p /usr/src; \
    cd /usr/src; \
    \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
        echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
        curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
        export GNUPGHOME="$(mktemp -d)"; \
        for key in $GPG_KEYS; do \
            gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
        done; \
        gpg --batch --verify php.tar.xz.asc php.tar.xz; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
    fi; \
    \
    apk del --no-network .fetch-deps

COPY docker-php-source /usr/local/bin/

RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
            $PHPIZE_DEPS \
            argon2-dev \
            coreutils \
            curl-dev \
            gnu-libiconv-dev \
            libsodium-dev \
            libxml2-dev \
            linux-headers \
            oniguruma-dev \
            openssl-dev \
            readline-dev \
            sqlite-dev \
    ; \
    \
    rm -vf /usr/include/iconv.h; \
    \
    ln -sv /usr/include/gnu-libiconv/*.h /usr/include/; \
    \
    export \
            CFLAGS="$PHP_CFLAGS" \
            CPPFLAGS="$PHP_CPPFLAGS" \
            LDFLAGS="$PHP_LDFLAGS" \
    ; \
    docker-php-source extract; \
    cd /usr/src/php; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
            --build="$gnuArch" \
            --with-config-file-path="$PHP_INI_DIR" \
            --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
            --enable-option-checking=fatal \
            --enable-mysqlnd \
            --enable-bcmath \
            --with-mhash \
            --with-pic \
            --enable-mbstring \
            --enable-mysqlnd \
            --with-password-argon2 \
            --with-sodium=shared \
            --with-pdo-mysql=mysqlnd \
            --with-mysqli=mysqlnd \
            --with-pdo-sqlite=/usr \
            --with-sqlite3=/usr \
            --with-curl \
            --with-iconv=/usr \
            --with-openssl \
            --with-readline \
            --with-zlib \
            --with-pear \
            --enable-sockets \
            --enable-pcntl \
            --enable-sysvmsg \
            --enable-sysvsem \
            --enable-sysvshm \
            \
            $(test "$gnuArch" = 's390x-linux-musl' && echo '--without-pcre-jit') \
    ; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    find \
            /usr/local \
            -type f \
            -perm '/0111' \
            -exec sh -euxc \
                ' strip --strip-all "$@" || : ' -- '{}' + \
    ; \
    make clean; \
    \
    cp -v php.ini-* "$PHP_INI_DIR/"; \
    \
    cd /; \
    docker-php-source delete; \
    \
    runDeps="$( scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' )"; \
    apk add --no-cache $runDeps; \
    apk del --no-network .build-deps; \
    pecl update-channels; \
    rm -rf /tmp/pear ~/.pearrc; \
    php --version

COPY docker-php-ext-* /usr/local/bin/

RUN docker-php-ext-enable sodium

RUN apk add --no-cache libpng libpng-dev \
	&& docker-php-ext-configure gd \
	&& docker-php-ext-install -j$(nproc) gd \
	&& apk del libpng-dev \
	&& docker-php-ext-enable gd \
	&& rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* \
	&& apk add --no-cache icu-dev icu libzip-dev zip \
    \
	&& docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl \
	&& docker-php-ext-enable intl \
	\
	&& docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip \
	&& docker-php-ext-enable zip \
	\
    && set -ex \
    && wget -nv -O /usr/local/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod u+x /usr/local/bin/composer \
    \
    && set -ex \
    && curl -L -o /tmp/redis.tar https://pecl.php.net/get/redis-5.3.2.tgz \
    && cd /tmp/ \
    && tar -zxvf /tmp/redis.tar \
    && mkdir -p /usr/src/php/ext \
    && cp -r ./redis-5.3.2 /usr/src/php/ext/redis \
    && cd /usr/src/php/ext/redis \
    && docker-php-ext-install -j$(nproc) redis \
	&& docker-php-ext-enable redis \
	\
	&& rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* \
	&& docker-php-source delete

RUN set -ex \
    # for swoole extension libaio linux-headers
    && apk add --no-cache libstdc++ libaio-dev openssl-dev curl-dev \
    && ls -alh \
    # download
    \
    && cd /tmp/ \
    && curl -L -o /tmp/swoole.tar "https://pecl.php.net/get/swoole-4.8.8.tgz" \
    && tar -zxvf /tmp/swoole.tar \
    && mkdir -p /usr/src/php/ext \
    && cp -r ./swoole-4.8.8 /usr/src/php/ext/swoole \
    && cd /usr/src/php/ext/swoole \
    && docker-php-ext-configure swoole --enable-openssl --enable-http2 --enable-swoole-curl --enable-swoole-json \
    && docker-php-ext-install -j$(nproc) swoole \
	&& docker-php-ext-enable swoole \
    \
    && cd /tmp \
    && curl -L -o /tmp/protobuf.tar "https://pecl.php.net/get/protobuf-3.21.5.tgz" \
    && tar -zxvf /tmp/protobuf.tar \
    && mkdir -p /usr/src/php/ext \
    && cp -r ./protobuf-3.21.5 /usr/src/php/ext/protobuf \
    && cd /usr/src/php/ext/protobuf \
    && docker-php-ext-install -j$(nproc) protobuf \
	&& docker-php-ext-enable protobuf \
    \
    # ---------- clear works ----------
    && apk del --purge *-dev \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
	&& docker-php-source delete \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

RUN apk add libzip-dev zip \
    && rm -rf /usr/local/bin/phpdbg \
    && rm -rf /usr/local/bin/php-cgi

WORKDIR /var/www

