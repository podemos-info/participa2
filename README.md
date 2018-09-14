# participa2

Citizen Participation and Open Government application.

This is the open-source repository for participa2, based on [Decidim].

## Setting up the application

You will need to do some steps before having the app working properly once
you've deployed it:

1. Open a Rails console in the server: `bundle exec rails console`

1. Create a System Admin user:

```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```

1. Visit `<your app url>/system` and login with your system admin credentials

1. Create a new organization. Check the locales you want to use for that
   organization, and select a default locale.

1. Set the correct default host for the organization, otherwise the app will not
   work properly. Note that you need to include any subdomain you might be
   using.

1. Fill the rest of the form and submit it.

You're good to go!

## Deploy

```
bundle exec cap staging systemd:hutch:setup
bundle exec cap staging systemd:puma:setup
bundle exec cap staging deploy
```

[Decidim]: https://github.com/decidim/decidim
