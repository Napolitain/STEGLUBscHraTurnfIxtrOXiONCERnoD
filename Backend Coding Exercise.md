# Statistically Thinking

The goal of this exercise is to demonstrate your ability to think critically,
while being creative and practical. We value clean solutions *that work*, and
thus the goal is not to determine your ability to use the "technology flavor of
the month", nor to evaluate your knowledge of esoteric meta-programming.

This exercise is estimated to take approximately two to three hours of your time.

Should you have questions regarding this exercise, please contact
[Alex Migidandi](mailto:migi@apple.com), or your Apple Recruiter.

Good luck!

## Abstract
You have just joined a new team and they fill you in on the problem at hand:
stats! The team is trying to come up with a prototype that will help determine
their ability to produce an in-house web analysis platform that suits their
specific business needs.

After some discussion about the scope of the prototype, and its goals, the team
decides to task you with it.

## Goals

Your first goal is to come up with a Ruby on Rails application that allows its users to
access two distinct reports in the realm of web stats using a REST API:

1. Number of page views per URL, grouped by day, for the past 5 days;
2. Top 5 referrers for the top 10 URLs grouped by day, for the past 5 days.

Your prototype should make use of Ruby, PostgreSQL, and any other gems you
determine necessary. Please, no GPL licenses.

The produced source code can be delivered via a public [Github](http://github.com)
repository or email to [Alex Migidandi](mailto:migi@apple.com).

## The dataset

As you dig into this challenge, the first order of business is to come up with a
*test* dataset, with exactly 1 million records, that you can use as a baseline
for your endeavor. From the outset, you'll want to be able to regenerate this
dataset at any given point in time, even if teh net result varies, and you will also
want to store it in a PostgreSQL table with the following structure:

| id (integer) | url (text)     | referrer (null text)   | created_at (datetime)     | hash (character(32))                   |
| :----------- | :---------------- | :------------------------ | :------------------------ | :------------------------------- |
| 1            | http://apple.com  | http://store.apple.com/us | 2017-01-01T00:00:00+00:00 | c5784530a4989491ab897f8d9d1555ad |
| 2            | https://apple.com | null                      | 2017-01-20T08:21:10+00:00 | da029aad12ad6e25f5035c6e4a18407a |

### Dataset requirements

Please observe the following requirements when generating your test dataset:

#### `id`

A sequential integer that uniquely identifies the record.

#### `url`

The url (string) that an end-user visited on your website.

Your dataset should include these URLs at least once:

* http://apple.com
* https://apple.com
* https://www.apple.com
* http://developer.apple.com
* http://en.wikipedia.org
* http://opensource.org

#### `referrer`

The optional referrer url (string) that indicates the page the user came from.

Your dataset should include these referrers at least once:

* http://apple.com
* https://apple.com
* https://www.apple.com
* http://developer.apple.com
* `NULL`

#### `created_at`
Indicates the date and time at which the URL was visited by the user. Please
note that your data should contain at least 10 distinct and sequential days.

#### `hash`
The MD5 hexdigest of a hash containing the aforementioned columns, modulo
those whose value is null. 

Example:
`Digest::MD5.hexdigest({id:1, url: 'http://apple.com', referrer: 'http://store.apple.com/us', created_at: Time.utc(2017,1,1)}.to_s)`

## The reports
Now that you have your test data, you're ready to start tackling the two
reports that the team has agreed to prototype.

### Report #1

The end-user should be able to access a REST endpoint in your application in
order to retrieve the number of page views per URL, grouped by day, for the past
5 days.

Example request:

	`[GET] /top_urls`

Payload
> { '2017-01-01' : [ { 'url': 'http://apple.com', 'visits': 100 } ] }

### Report #2

Your end-users should be able to retrieve the top 5 referrers for the top 10
URLs grouped by day, for the past 5 days, via a REST endpoint.

Example request:

	`[GET] /top_referrers`

Payload
> {
>	'2017-01-01' : [
>		{
>			'url': 'http://apple.com',
>			'visits': 100,
>			'referrers': [ { 'url': 'http://store.apple.com/us', 'visits': 10 } ]
>		}
>	]
>}

## Performance

We value tested code that performs well under heavy load.