#!/bin/sh

## The list of benchmarks to run
BENCHMARKS_TO_RUN="${@}"
##  ...or use all the *_bench dirs by default
BENCHMARKS_TO_RUN="${BENCHMARKS_TO_RUN:-$(find . -maxdepth 1 -name '*_bench' -type d | sort)}"

RESULTS_DIR="results/$(date '+%y%d%mT%H%M%S')"
GRPC_BENCHMARK_DURATION=${GRPC_BENCHMARK_DURATION:-"30s"}
GRPC_SERVER_CPUS=${GRPC_SERVER_CPUS:-"1"}
GRPC_SERVER_RAM=${GRPC_SERVER_RAM:-"512m"}
GRPC_CLIENT_CONNECTIONS=${GRPC_CLIENT_CONNECTIONS:-"5"}
GRPC_CLIENT_CONCURRENCY=${GRPC_CLIENT_CONCURRENCY:-"50"}
GRPC_CLIENT_QPS=${GRPC_CLIENT_QPS:-"0"}
GRPC_CLIENT_QPS=$(( GRPC_CLIENT_QPS / GRPC_CLIENT_CONCURRENCY ))
GRPC_CLIENT_CPUS=${GRPC_CLIENT_CPUS:-"1"}
GRPC_REQUEST_PAYLOAD=${GRPC_REQUEST_PAYLOAD:-"100B"}

# Let containers know how many CPUs they will be running on
export GRPC_SERVER_CPUS
export GRPC_CLIENT_CPUS

docker pull infoblox/ghz:0.0.1
# docker run --name ghz --rm --network=host -v "${PWD}/proto:/proto:ro"\
#     -v "${PWD}/payload:/payload:ro"\
#     --cpus $GRPC_CLIENT_CPUS \
#     --entrypoint=ghz infoblox/ghz:0.0.1 \
#     --proto=/proto/helloworld/helloworld.proto \
#     --call=helloworld.Greeter.SayHello \
#     --insecure \
#     --concurrency="${GRPC_CLIENT_CONCURRENCY}" \
#     --connections="${GRPC_CLIENT_CONNECTIONS}" \
#     --qps="${GRPC_CLIENT_QPS}" \
#     --duration "${GRPC_BENCHMARK_DURATION}" \
#     --data-file /payload/"${GRPC_REQUEST_PAYLOAD}" \
#     127.0.0.1:50051 

# export GRPC_BENCHMARK_DURATION=30s
# export GRPC_SERVER_CPUS=3
# export GRPC_SERVER_RAM=512m
# export GRPC_CLIENT_CONNECTIONS=5
# export GRPC_CLIENT_CONCURRENCY=50
# export GRPC_CLIENT_QPS=0
# export GRPC_CLIENT_CPUS=9
# export GRPC_REQUEST_PAYLOAD=100B

# assign specific CPUs to client and server so the client does not
# content with the server for resources.
ASSIGNED_CPUS_CLIENT="0-$((${GRPC_CLIENT_CPUS} - 1))"
ASSIGNED_CPUS_SERVER="${GRPC_CLIENT_CPUS}-$((${GRPC_CLIENT_CPUS} + ${GRPC_SERVER_CPUS} - 1))"
#echo "Assigned server CPUs: ${ASSIGNED_CPUS_SERVER}"
echo "Assigned client CPUs: ${ASSIGNED_CPUS_CLIENT}"

docker run --name ghz --rm --network=host -v "${PWD}/proto:/proto:ro"\
    -v "${PWD}/payload:/payload:ro"\
    --cpuset-cpus "${ASSIGNED_CPUS_CLIENT}" \
    --entrypoint=ghz infoblox/ghz:0.0.1 \
    --proto=/proto/helloworld/helloworld.proto \
    --call=helloworld.Greeter.SayHello \
    --insecure \
    --concurrency="${GRPC_CLIENT_CONCURRENCY}" \
    --connections="${GRPC_CLIENT_CONNECTIONS}" \
    --qps="${GRPC_CLIENT_QPS}" \
    --duration "${GRPC_BENCHMARK_DURATION}" \
    --data-file /payload/"${GRPC_REQUEST_PAYLOAD}" \
    127.0.0.1:50051

