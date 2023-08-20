"""Module for getting os type."""
import os
import sys
import subprocess
from python_terraform import Terraform, IsFlagged
from yaml import safe_load, YAMLError


def build(
    template: str,
    _alicloud_ak: str,
    _alicloud_sk: str,
    _alicloud_region: str,
    _availability_zone: str,
    _ecs_type: str,
    _main_domain: str,
    _cloudflare_api_token: str,
    _cloudflare_zone_id: str,
    _github_client_id: str,
    _github_client_secret: str,
) -> dict:
    """_summary_

    Args:
        template (str): _description_
        _alicloud_ak (str): _description_
        _alicloud_sk (str): _description_
        _alicloud_region (str): _description_
        _availability_zone (str): _description_
        _ecs_type (str): _description_
        _main_domain (str): _description_
        _cloudflare_api_token (str): _description_
        _cloudflare_zone_id (str): _description_
        _github_client_id (str): _description_
        _github_client_secret (str): _description_

    Returns:
        dict: _description_
    """
    tf_instance = Terraform(working_dir=template)
    ret, stdout, stderr = tf_instance.apply(
        capture_output=True,
        no_color=IsFlagged,
        skip_plan=True,
        var={
            "main_domain": _main_domain,
            "cloudflare_zone_id": _cloudflare_zone_id,
            "cloudflare_api_token": _cloudflare_api_token,
            "alicloud_access_key": _alicloud_ak,
            "alicloud_secret_key": _alicloud_sk,
            "alicloud_region": _alicloud_region,
            "availability_zone": _availability_zone,
            "ecs_type": _ecs_type,
            "github_client_id": _github_client_id,
            "github_client_secret": _github_client_secret,
        },
    )
    if stdout:
        # print(stdout)
        subprocess.call(f"chmod 600 {template}/keys/temp_key.pem")
        return tf_instance.output()
    if stderr:
        print(stderr)
    return {}


def destroy(
    template: str,
    _alicloud_ak: str,
    _alicloud_sk: str,
    _alicloud_region: str,
    _availability_zone: str,
    _ecs_type: str,
    _main_domain: str,
    _cloudflare_api_token: str,
    _cloudflare_zone_id: str,
    _github_client_id: str,
    _github_client_secret: str,
) -> None:
    """_summary_

    Args:
        template (str): _description_
        _alicloud_ak (str): _description_
        _alicloud_sk (str): _description_
        _alicloud_region (str): _description_
        _availability_zone (str): _description_
        _ecs_type (str): _description_
        _main_domain (str): _description_
        _cloudflare_api_token (str): _description_
        _cloudflare_zone_id (str): _description_
        _github_client_id (str): _description_
        _github_client_secret (str): _description_
    """
    tf_instance = Terraform(working_dir=template)
    ret, stdout, stderr = tf_instance.destroy(
        capture_output=True,
        auto_approve=True,
        force=None,
        var={
            "main_domain": _main_domain,
            "cloudflare_zone_id": _cloudflare_zone_id,
            "cloudflare_api_token": _cloudflare_api_token,
            "alicloud_access_key": _alicloud_ak,
            "alicloud_secret_key": _alicloud_sk,
            "alicloud_region": _alicloud_region,
            "availability_zone": _availability_zone,
            "ecs_type": _ecs_type,
            "github_client_id": _github_client_id,
            "github_client_secret": _github_client_secret,
        },
    )
    if stdout:
        print("[*] Hyperlog platform Build destruction complete!\n")
    if stderr:
        print(stderr)


def main():
    """_summary_
    Pull configuration from config.yaml, build , waiting for destory.

    Args:
        None
    """
    # 加载配置
    _template: str = "templates"
    _alicloud_ak: str = ""
    _alicloud_sk: str = ""
    _alicloud_region: str = ""
    _availability_zone: str = ""
    _ecs_type: str = ""
    _main_domain: str = ""
    _cloudflare_api_token: str = ""
    _cloudflare_zone_id: str = ""
    _github_client_id: str = ""
    _github_client_secret: str = ""

    if os.name == "nt":
        print("[!] This tool requires the Linux operating system. Exiting.\n")
        sys.exit(1)

    print("[*] Pulling configuration from config.yaml")
    try:
        with open("config.yaml", "r", encoding="utf-8") as file:
            data = safe_load(file)
            _alicloud_ak = data["alicloud"]["ak"]
            _alicloud_sk = data["alicloud"]["sk"]
            _alicloud_region = data["alicloud"]["region"]
            _availability_zone = data["alicloud"]["availability_zone"]
            _ecs_type = data["alicloud"]["ecs_type"]
            _cloudflare_api_token = data["cloudflare"]["api_token"]
            _cloudflare_zone_id = data["cloudflare"]["zone_id"]
            _main_domain = data["cloudflare"]["main_domain"]
            _github_client_id = data["github"]["client_id"]
            _github_client_secret = data["github"]["client_secret"]
    except (OSError, YAMLError):
        print("[!] Error parsing the YAML configuration file.\n")
        exit(1)
    print("[*] Building platform...")
    output: dict = build(
        _template,
        _alicloud_ak,
        _alicloud_sk,
        _alicloud_region,
        _availability_zone,
        _ecs_type,
        _main_domain,
        _cloudflare_api_token,
        _cloudflare_zone_id,
        _github_client_id,
        _github_client_secret,
    )
    print("[*] Output from build...")
    for output_iterm in output:
        print(f"Instance {output_iterm} has IP {output[output_iterm]['value']}")
        print(f"Hyperlog platform URL: https://log.{_main_domain}")
        print(f"Template SSH public key file location: f{_template}/keys/temp_key.pem")
    input("\nPress any key to destroy build...")
    print("[*] Destroying network...")
    destroy(
        _template,
        _alicloud_ak,
        _alicloud_sk,
        _alicloud_region,
        _availability_zone,
        _ecs_type,
        _main_domain,
        _cloudflare_api_token,
        _cloudflare_zone_id,
        _github_client_id,
        _github_client_secret,
    )


if __name__ == "__main__":
    main()
