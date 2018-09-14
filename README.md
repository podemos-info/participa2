# participa2

Citizen Participation and Open Government application.

This is the open-source repository for participa2, a web application based on
[Decidim]. Decidim is a framework for participatory democracy, you can find more
about it at its [documentation page][decidim docs].

Note that whereas decidim is a _library_, participa2 is a _final application_
that uses Decidim. More specifically, participa2 is a [Rails] application,
whereas decidim is a [rubygem] that provides a set of [Rails Engines] to the
application using it.

On top of decidim's default functionality, participa2 adds some extra
functionality implemented as decidim components. These custom components live
inside the participa2 repo and are the following:

* [Census Connector]: Basic connection to a census of people that belong to the
  organization.

* [Crowdfundings]: Crowdfunding campaings for the democractic activity that
  takes places inside the organization.

* [Gravity Forms]: Form management interface to the Gravity Forms [Wordpress
  Plugin][Gravity Forms Wordpress Plugin].

* [Votings]: Votings interface to custom secure external voting systems.

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

```console
bundle exec cap staging systemd:hutch:setup
bundle exec cap staging systemd:puma:setup
bundle exec cap staging deploy
```

[Decidim]: https://github.com/decidim/decidim
[decidim docs]: https://docs.decidim.org
[Rails]: https://rubyonrails.org
[Rubygem]: https://rubygems.org
[Rails Engines]: https://guides.rubyonrails.org/engines.html
[Gravity Forms Wordpress Plugin]: https://www.gravityforms.com

[Census Connector]: decidim-module-census_connector/README.md
[Crowdfundings]: decidim-module-crowdfundings/README.md
[Gravity Forms]: decidim-module-gravity_forms/README.md
[Votings]: decidim-module-votings/README.md
