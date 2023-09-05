define build_image
	name=$(1); \
    dockerfile=$(2); \
    platform=$(3); \
    version=$(4); \
    owner=$(5); \
    if [ -d "$(1)" ]; then \
        echo "build $(1) $(3)"; \
        cd $(1); \
        docker buildx build -f $(2) --platform linux/arm64,linux/amd64 --push -t justcy/$(1):$(3) .; \
        cd ..; \
    fi;\
    docker system prune -f 
endef

.PHONY: php
php:
	$(call build_image,php,Dockerfile-7.4.27,7.4.27) 
.PHONY: php-swoole
php-swoole:
	$(call build_image,php,Dockerfile-swoole4.6.1-php7.4,7.4.27-swoole)
.PHONY: beanstalkd
beanstalkd:
	$(call build_image,beanstalkd,Dockerfile,1.13)
