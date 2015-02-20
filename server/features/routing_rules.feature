Feature: Routing Scheme and Routing Rules

    @auth
    Scenario: List empty routing schemes
      Given empty "routing_schemes"
      When we get "/routing_schemes"
      Then we get list with 0 items

    @auth
    Scenario: Create a valid Routing Scheme
      Given empty "desks"
      When we post to "/desks"
      """
      {"name": "Sports", "members": [{"user": "#users._id#"}]}
      """
      And we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              }
            }
          ]
        }
      ]
      """
      Then we get response code 201
      When we get "/routing_schemes"
      Then we get existing resource
      """
      {
        "_items":
          [
            {
              "name": "routing rule scheme 1",
              "rules": [
                {
                  "name": "Sports Rule",
                  "filter": {
                    "category": [{"name": "Overseas Sport", "qcode": "S"}]
                  },
                  "actions": {
                    "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
                  }
                }
              ]
            }
          ]
      }
      """

    @auth
    Scenario: A Routing Scheme must have a unique name
      Given empty "desks"
      When we post to "/desks"
      """
      {"name": "Sports", "members": [{"user": "#users._id#"}]}
      """
      And we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              }
            }
          ]
        }
      ]
      """
      Then we get response code 201
      When we post to "/routing_schemes"
      """
      [
        {
          "name": "ROUTING rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              }
            }
          ]
        }
      ]
      """
      Then we get response code 400

    @auth
    Scenario: Create an invalid Routing Scheme with no rules
      Given empty "routing_schemes"
      When we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": []
        }
      ]
      """
      Then we get response code 400

    @auth
    Scenario: Create an invalid Routing Scheme with rules having same name
      Given empty "routing_schemes"
      When we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Australian News", "qcode": "A"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              }
            },
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              }
            }
          ]
        }
      ]
      """
      Then we get response code 400

    @auth
    Scenario: Create an invalid Routing Scheme with an empty filter
      Given empty "routing_schemes"
      When we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [{
            "name": "Sports Rule",
            "filter": {}
          }]
        }
      ]
      """
      Then we get response code 400

    @auth
    Scenario: Create an invalid Routing Scheme with a empty actions
      Given empty "routing_schemes"
      When we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [{
            "name": "Sports Rule",
            "filter": {
              "category": [{"name": "Overseas Sport", "qcode": "S"}]
            },
            "actions": {}
          }]
        }
      ]
      """
      Then we get response code 400

    @auth
    Scenario: Create an invalid Routing Scheme with a empty schedule
      Given empty "users"
      And empty "desks"
      When we post to "users"
      """
      {"username": "foo", "email": "foo@bar.com", "is_active": true}
      """
      And we post to "/desks"
      """
      {"name": "Sports", "members": [{"user": "#users._id#"}]}
      """
      And we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              },
              "schedule": {}
            }
          ]
        }
      ]
      """
      Then we get response code 400

    @auth
    Scenario: A user with no privilege to "routing schemes" can't create a Routing Scheme
      Given we login as user "foo" with password "bar"
      """
      {"user_type": "user", "email": "foo.bar@foobar.org"}
      """
      When we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              },
              "schedule": {}
            }
          ]
        }
      ]
      """
      Then we get response code 403

    @auth
    Scenario: Update Routing Scheme
      Given empty "desks"
      When we post to "/desks"
      """
      {"name": "Sports"}
      """
      And we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              }
            }
          ]
        }
      ]
      """
      Then we get response code 201
      When we patch "/routing_schemes/#routing_schemes._id#"
      """
      {
        "rules": [
          {
            "name": "Australian News Rule",
            "filter": {
              "category": [{"name": "Australian News", "qcode": "A"}]
            },
            "actions": {
              "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
            }
          },
          {
            "name": "Sports Rule",
            "filter": {
              "category": [{"name": "Overseas Sport", "qcode": "S"}]
            },
            "actions": {
              "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
            }
          }
        ]
      }
      """
      Then we get response code 200

    @auth
    Scenario: Delete a Routing Scheme
      Given empty "desks"
      When we post to "/desks"
      """
      {"name": "Sports"}
      """
      And we post to "/routing_schemes"
      """
      [
        {
          "name": "routing rule scheme 1",
          "rules": [
            {
              "name": "Sports Rule",
              "filter": {
                "category": [{"name": "Overseas Sport", "qcode": "S"}]
              },
              "actions": {
                "fetch": [{"desk": "#desks._id#", "stage": "#desks.incoming_stage#"}]
              }
            }
          ]
        }
      ]
      """
      Then we get response code 201
      When we delete "/routing_schemes/#routing_schemes._id#"
      Then we get response code 204
