type Swift::MountDevice = Variant[
  Stdlib::Absolutepath,
  Pattern[/^LABEL=.+$/],
  Pattern[/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$/],
  Pattern[/^UUID=[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$/],
]
