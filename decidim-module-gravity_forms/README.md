# Decidim::GravityForms

A gravity forms component for Decidim.

## Usage

It loads a gravity form inside an iframe on a component of a participatory
space. The remote wordpress instance to load forms from is configurable as a
global component setting. The wordpress instance needs [Gravity
Forms](https://www.gravityforms.com/) and the [gravity forms iframe
plugin](https://github.com/cedaro/gravity-forms-iframe) installed.

Also, any gravity form you try to embed needs to have the "Allow this form to be
embedded in an iframe" setting added by the mentioned plugin checked.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-gravity_forms
```

And then execute:

```bash
bundle
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
