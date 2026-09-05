# Worksheet Host

Small, offline-friendly Rails app that turns plain-text worksheet templates into fillable web forms for iPhone Safari. Designed to run on a Raspberry Pi 4 on a home LAN.

## Stack

- Ruby 4.0.5
- Rails 7.2.3
- SQLite
- Hotwire (Turbo/Stimulus) + local assets (no CDN)

## Worksheet format

UTF-8 `.txt` files:

- Two or more underscores (`______`) → one text input
- Exact `[ ]` → one checkbox
- Everything else is static text

Drop files into the intake directory; the app discovers them automatically.

## Local development

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Data defaults to `tmp/worksheet_host_data/` (`intake/`, `templates/`, `exports/`, `db/`).

```bash
cp deploy/sample_intake/car_check.txt tmp/worksheet_host_data/intake/
```

Open http://localhost:3000

```bash
bin/rails test
```

Override the data root with `WORKSHEET_HOST_DATA_ROOT`.

## Production layout (Raspberry Pi)

```text
/mnt/raid1/apps/worksheet_host/     # git checkout / app code
/mnt/raid1/data/worksheet_host/
    intake/
    templates/
    exports/
    db/
    logs/
```

Application upgrades under `apps/` must never delete data under `data/`.

### systemd

1. Create a non-root user (e.g. `worksheet`) that owns the data directory.
2. Checkout the app to `/mnt/raid1/apps/worksheet_host`.
3. Copy `deploy/worksheet_host.env.example` → `deploy/worksheet_host.env` and set `RAILS_MASTER_KEY`.
4. `bundle install --deployment` and `RAILS_ENV=production bin/rails db:prepare assets:precompile`
5. Install the unit:

```bash
sudo cp deploy/worksheet_host.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now worksheet_host
```

Logs: `journalctl -u worksheet_host -f`

### Backup

Copy `/mnt/raid1/data/worksheet_host/db`, `templates`, `intake`, and optionally `exports`.

### Acceptance sample

`deploy/sample_intake/car_check.txt` matches the Car Check end-to-end scenario from the product spec.
