﻿using Microsoft.Azure.ServiceBus.Core;

namespace PSServiceBus.Helpers
{
    public interface ISbSender
    {
        MessageSender messageSender { get; set; }

        void SendMessage(string MessageBody);
    }
}