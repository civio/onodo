# in development you should keep it set to 1 to ease debugging
worker_processes ENV['WORKER_PROCESSES'].to_i

# Listen on a tcp port or unix socket
listen ENV['LISTEN_ON']

# to allow handling large uploads
timeout 240

# log to stdout
logger Logger.new($stdout)
