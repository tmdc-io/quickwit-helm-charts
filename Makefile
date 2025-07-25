CH_DIR = charts/quickwit
DIR = quickwit
VERSION = ${TAG}
PACKAGED_CHART = ${DIR}-${VERSION}.tgz

push-oci-chart:
	@echo
	@echo "=== login to OCI registry ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo
	@echo "=== package OCI chart ==="
	helm package ${CH_DIR} --version ${VERSION}
	@echo
	@echo "=== create repository ==="
	aws ecr describe-repositories --repository-names ${DIR} --no-cli-pager || aws ecr create-repository --repository-name ${DIR} --region $(AWS_DEFAULT_REGION) --no-cli-pager
	@echo
	@echo "=== push OCI chart ==="
	helm push ${PACKAGED_CHART} oci://$(ECR_HOST)
	@echo
	@echo "=== logout of registry ==="
	helm registry logout $(ECR_HOST)