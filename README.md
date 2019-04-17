# Tako

Tako is an extension to Torch for more flexible creation of information systems, especially neural networks. It divides classes into three components.

- Members
- Methods
- Processes


```
local Autoencoder = oc.tako('oc.Autoencoder')

Autoencoder.arm.encode = nn.Linear:d(2, 4) .. nn.Sigmoid:d()
Autoencoder.arm.decode = nn.Linear:d(4, 2) .. nn.Sigmoid:d()
Autoencoder.arm.autoencode = oc.r(oc.my.encode) .. oc.r(oc.my.decode)

local autoencoder = Autoencoder()
autoencoder.regenerate:stimulate(torch.rand(2))
```

It also includes other ways to flexibly define information networks and to traverse those networks.


# Info

The usage of Tako is explained more in depth in the Wiki pages.
[Wiki](https://github.com/short-greg/tako/wiki)

## Installation

Since Tako extends Torch, first you will need to install Torch. The instructions for installing Torch can be found here
[Torch](http://torch.ch/)

After installing Torch, you should clone the repository and then install the Tako.

```
git clone https://github.com/short-greg/tako.git
cd tako
luarocks make
```
