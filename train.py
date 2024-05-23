from model import Net

import torch
from torch import nn, optim
from torch.nn import functional as F
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from torchvision.utils import save_image
import os

import wandb
from wandb import AlertLevel
wandb.login()

def train_withwandb(
        model,
        trainloader,
        optimizer,
        criterion,
        epochs):

    for epoch in range(epochs):
        train_loss=0.0
        
        for i, data in enumerate(trainloader, 0):
            inputs, labels = data
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            train_loss += loss.item()
            print(f"Epoch {epoch+1} loss: {running_loss/len(trainloader)}")
            # for wandb
            wandb.log({"loss": train_loss/len(trainloader), "epoch": epoch})



# setting device
#gpu_device = "mps"
device = torch.device("mps" if torch.cuda.is_available() else "cpu")
print(device)

# setting data_loader
trainset = datasets.MNIST(root='./data', train=True, download=True, transform=transforms.ToTensor())
testset = datasets.MNIST(root='./data', train=False, download=True, transform=transforms.ToTensor())
trainloader = torch.utils.data.DataLoader(trainset, batch_size=32, shuffle=True, num_workers=2)
testloader = torch.utils.data.DataLoader(testset, batch_size=32, shuffle=False, num_workers=2)


model = Net() #.to(device)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=1e-3)

config_dict={
    "model": model,
    "trainloader": trainloader,
    "optimizer": optimizer,
    "criterion": criterion,
    "epochs": 10,
}


with wandb.init(
        project="test_wandb",
        group="tutorial",
        config=config_dict,
        name="test_run"):

    train_withwandb(**config_dict)

    wandb.alert(
        title="test_wandb",
        text="to sora, finish training",
        level=AlertLevel.INFO
    )

wandb.finish()
