# frozen_string_literal: true

class MailboxesController < ApplicationController
  before_action :set_domain
  before_action :set_mailbox, only: %i[show update destroy]

  def index
    @mailboxes = @domain.mailboxes

    render json: @mailboxes.as_json(except: [:password]), status: :ok
  end

  def create
    @mailbox = @domain.mailboxes.new(mailbox_params)

    return render json: @mailbox.as_json(except: [:password]), status: :created if @mailbox.save

    render json: @mailbox.errors, status: :unprocessable_entity
  end

  def show
    render json: @mailbox.as_json(except: [:password])
  end

  def update
    return render json: @mailbox.as_json(except: [:password]) if @mailbox.update(mailbox_params)

    render json: @mailbox.errors, status: :unprocessable_entity
  end

  def destroy
    @mailbox.destroy
  end

  private

  def mailbox_params
    params.require(:mailbox).permit(:username, :password)
  end

  def set_domain
    @domain = Domain.find(params[:domain_id])
  end

  def set_mailbox
    @mailbox = @domain.mailboxes.find(params[:id])
  end
end
