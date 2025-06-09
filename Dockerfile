FROM golang:1.22.5 as base
WORKDIR /app
# Copy go.mod and go.sum files to the working directory
# This allows us to cache dependencies and avoid re-downloading them on every build
COPY go.mod .
# Download the dependencies
# This step is separated to leverage Docker's caching mechanism
RUN go mod download
# Copy the rest of the application code to the working directory
COPY . .
RUN go build -o main .

#final stage - distroless image
# Use a minimal base image for the final build
FROM gcr.io/distroless/base

# Copy the built binary from the base image to the final image
# This will copy the binary named 'main' from the /app directory in the base image to the /app directory in the final image
COPY --from=base /app/main .

COPY --from=base /app/static ./static

EXPOSE 8080

CMD [ "./main" ]