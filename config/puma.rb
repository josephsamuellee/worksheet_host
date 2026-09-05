# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Bind on all interfaces so LAN devices (e.g. iPhone) can reach the Pi.
port_number = ENV.fetch("PORT", 3000)
bind_host = ENV.fetch("PUMA_BIND", "0.0.0.0")
bind "tcp://#{bind_host}:#{port_number}"

plugin :tmp_restart

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
