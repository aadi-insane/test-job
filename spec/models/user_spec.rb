require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has an email' do
    user = User.new(
      email: '',
      password: "123456",
      role: 'contributor',
      name: 'User Name'
    )

    expect(user).not_to be_valid
    user.email = 'random_email'
    expect(user).to_not be_valid
    user.email = 'proper@emailsyntax.com'
    expect(user).to be_valid
  end
  it 'has an password' do
    user = User.new(
      email: 'proper@emailsyntax.com',
      password: '',
      role: 'contributor',
      name: 'User Name'
    )

    expect(user).not_to be_valid
    user.password = 'short'
    expect(user).to_not be_valid
    user.password = '123456'
    expect(user).to be_valid
    
  end
  it 'has a role' do
    user = User.new(
      email: 'proper@emailsyntax.com',
      password: '123456',
      role: '',
      name: 'User Name'
    )

    expect(user).not_to be_valid
    # user.role = 'random_role'
    # expect(user).to raise_error(ArgumentError)
    user.role = 'contributor'
    expect(user).to be_valid
    user.role = 'manager'
    expect(user).to be_valid
    user.role = 'admin'
    expect(user).to be_valid
  end
  it 'has a name' do
    user = User.new(
      email: 'proper@emailsyntax.com',
      password: '123456',
      role: 'contributor',
      name: ''
    )

    expect(user).to be_valid
    user.name = 'User Name'
    expect(user).to be_valid
  end
end
