class TransactionSerializer < ActiveModel::Serializer
  attributes :amount, :type, :event, :sender, :receiver, :time

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

  def time
    Formatters::DateFormater.format_with_time(object.created_at)
  end
end
