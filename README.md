Viadeo Scraper
================

viadeo-scraper is a gem for scraping viadeo public profiles.


##Installation

Install the gem from RubyGems:

```ruby
    gem install viadeo-scraper
```

##Usage

```ruby
profile = Viadeo::Profile.get_profile(url)
#profile = Viadeo::Profile.get_profile(url, {:proxy_ip=>'127.0.0.1',:proxy_port=>'3128'})

profile.first_name
profile.last_name
profile.name
profile.title
profile.summary
profile.location
profile.country
profile.social_links
profile.industry
profile.picture
profile.skills
profile.education
profile.current_companies
profile.past_companies
profile.groups
profile.languages
profile.recommended_visitors
```
