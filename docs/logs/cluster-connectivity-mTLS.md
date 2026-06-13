|**Connection Type**|**Who defines the Identity?**|**Protocol**|**Senior Audit Question**|
|---|---|---|---|
|**Pod-to-Pod**|**You** (Cilium/OpenBao)|mTLS|Is the certificate duration short enough?|
|**Pod-to-Cloud**|**Cloud Provider** (IAM/OIDC)|JWT Token|Is the IAM role restricted to the specific S3 bucket?|
|**Pod-to-Partner**|**Shared Agreement**|mTLS|Who is responsible for renewing the Client Certificate before it expires?|
