import sys

from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import urllib



priv_key = '-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQDM4m78ly6W/FEEwgXuJxKZ4ZctGX05iCkYsbRPVIEqz6O8YG90\nsKhzeR/NFZJuR4eFXlhoch+VrqfliE80Xp3pAu/TSLUsw/dCNldk/I35Rbp8mq0D\n5hEhlTiUi7tGpTKdBjGRkNYh+CaavG9aqc4DZDMG0zBEf3mHlJML0p3sRwIDAQAB\nAoGAcmrVnlvzWcBIooaT9z58xdDUswv0AcgHY1ICJvdDNxxEDTQxqhHp0KrI1qgA\nYXOyvAlHB/ULrHSgMK/hw5Y/SlvjyOyvY7fDMgdoD0Yb5dGWFE+Rsx2YJF/CnAQc\nHEObmf1SNTD7D5YzqAwHSWKBQh0MbmjydSAHEpqbDHRhkKECQQDXhMgcHkDQLmsV\nAxu7K7fVYGmMo2sPpI2//FPsv+o3nVNf/5bbMwtcBbg0KcY8QdgnBddUjKhNMgMn\nJwmfbMKRAkEA815Ou6LxW69PoZHnqe7LTvzbPxII7RBzPPsz+f1IL/JSA/N/tLgP\nwNIzEJb15qD1u/HzcwWT6UfwhrQKNLd9VwJBAKKAXP5OlWIjTdx3DobPjPpXit5f\nLc+KrNLwqDsf7bNnbcE5j37R+yO0sFKsmOtAXoH19omq0Q/7wMLZvXi24fECQF5e\nsn8WFytrVqCbWE7P1yyA5m+VibqLh3QdILGOoqBdAaqgkGO+f/VQTRbgwue0gLVp\ng/KVNh7ek4lYZSC+Ci8CQQCrOvo4eBoQoFinsmfIchN2FgUwDd2lFC3PkiO8bXR6\njVMnYN0MihRcSG4cESHxwb3vD+v87PMxNxua6OpQ1cPC\n-----END RSA PRIVATE KEY-----'

priv = RSA.importKey(priv_key)
cipher = PKCS1_OAEP.new(priv)

def id_decrypt(cipherText):
  cleartext = cipher.decrypt(urllib.unquote(cipherText))
  return str(cleartext)

#print cal1Id
  #print repr(cleartext)

if __name__ == '__main__':
  leaky_decrypt(*sys.argv[1:])