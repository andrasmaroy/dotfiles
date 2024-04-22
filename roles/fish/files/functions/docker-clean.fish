function docker-clean \
    --description 'Remove stopped docker containers and noname images'

    docker container prune -f
    docker volume prune -f
    docker images | grep '^<none>' | awk '{print $3}' | xargs docker rmi
end
