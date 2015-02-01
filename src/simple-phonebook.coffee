# Description:
#   Search hubot brain for contact information of an user
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot phonebook me <name> - Get contact information for <name>
#   hubot phonebook set (email|phone) of <name> to <value> - Saves the email or phone of the specified user
#
# Author:
#   anroots

module.exports = (robot) ->

  # Return a phonebook entry string for the user
  #
  # user - an user object from hubot brain
  getPhonebookEntry = (user) ->
    """
The contact details for *#{user.name}* are as follows:

- Phone: #{user.phone or '_unknown_'}
- Email: #{user.email or '_unknown_'}
"""

  # Searches for a user based on the input name
  findUser = (msg, name) ->

    # Find user from hubot brain using partial name matching
    users = robot.brain.usersForFuzzyName name

    # If more than one result was returned, exit with an error
    if users.length > 1
      robot.logger.debug "Too many matches for phonebook query to #{name}"
      msg.send 'Sorry, the phonebook contains several people ' +
        "called \"#{name}\". Could you be more specific?"
      return false

    # If no results were found, exit with an error
    if users.length is 0
      robot.logger.debug "No matches for phonebook query to #{name}"
      msg.send "I went through the whole phonebook, " +
        "but could not find an entry for \"#{name}\"."
      return false

    users[0]

  # Save user's contact information
  robot.respond /phonebook set (email|phone) of (.*) to (.*)/i, (msg) ->

    # Extract values from the input
    attribute = msg.match[1].toLowerCase()
    userName = msg.match[2]
    value = msg.match[3]

    # Find the user
    user = findUser msg, userName
    return unless user

    # Save the attribute value
    user[attribute] = value
    robot.brain.save()

    # Reply with the new values
    msg.send getPhonebookEntry user

  # Search user's contact information and return it
  robot.respond /phonebook me (.*)/i, (msg) ->

    # Get the name to search
    name = msg.match[1]
    robot.logger.debug "Searching for contact details for person #{name}"

    # Find the user
    user = findUser msg, name
    return unless user

    # All good, found exactly one entry, send it back to the user
    msg.send getPhonebookEntry user
