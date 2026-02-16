# Build the manager binary
FROM registry.access.redhat.com/ubi9/go-toolset:1.25@sha256:799cc027d5ad58cdc156b65286eb6389993ec14c496cf748c09834b7251e78dc AS builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
COPY ./Makefile ./Makefile
RUN go mod download

# Copy the Go sources
COPY main.go main.go
COPY pkg/ pkg/

USER root
RUN CGO_ENABLED=1 GOOS=linux GOARCH=${TARGETARCH:-amd64} make go-build-for-image

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest
WORKDIR /
COPY --from=builder /workspace/manager .

USER 65532:65532
ENTRYPOINT ["/manager"]
