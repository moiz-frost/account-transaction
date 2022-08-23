class TransactionSerializer < ActiveModel::Serializer
  attributes :amount, :type, :event, :sender, :receiver

  belongs_to :sender
  belongs_to :receiver

  def sender
    object.sender&.email || object.sender&.phone_number || ''
  end

  def receiver
    object.receiver&.email || object.receiver&.phone_number || ''
  end

  def amount
    object.formatted_amount
  end
end
