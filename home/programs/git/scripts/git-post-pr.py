import argparse
import json
import subprocess
import tkinter

# TODO: add support for gitea, and maybe other git hosting options.


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="post-pr",
        description="Post links to PRs",
    )

    parser.add_argument("-n", "--no-clipboard", action="store_true", help="do not copy the message to the clipboard")

    pr_id = parser.add_mutually_exclusive_group()
    pr_id.add_argument("-c", "--current-branch", action="store_true", help="generate post for the PR for the current branch")
    pr_id.add_argument("-l", "--latest", action="store_true", help="generate post for the latest PR for the current user")
    pr_id.add_argument("pr_id", nargs="?", default=None, help="generate post for the PR with the given ID")
    args = parser.parse_args()

    if not any([args.current_branch, args.latest, args.pr_id,]):
        args.current_branch = True

    return args


def _gh(args: list[str]) -> str:
    try:
        return subprocess.check_output(["gh"] + args).decode("utf8")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"GitHub CLI command failed: 'gh {' '.join(args)}'") from e


def _gh_retcode(args: list[str]) -> int:
    return subprocess.run(["gh"] + args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode


def ensure_gh_installed():
    try:
        if _gh_retcode(["--version"]) != 0:
            raise RuntimeError("GitHub CLI (gh) is not installed, please install it")
    except FileNotFoundError:
        raise RuntimeError("GitHub CLI (gh) is not installed, please install it")


def ensure_gh_authenticated():
    if _gh_retcode(["auth", "status"]) != 0:
        raise RuntimeError("Failed to authenticate with GitHub, please run 'gh auth login'")


GH_PR_JSON_FIELDS = ",".join([
    "additions",
    "deletions",
    "state",
    "title",
    "url",
])


def fetch_pr_data(current_branch: bool, latest: bool, pr_id: str | None) -> dict[str, any]:
    if pr_id:
        pr_data = _gh(["pr", "view", pr_id, "--json", GH_PR_JSON_FIELDS])
        pr_data = json.loads(pr_data)

    elif latest:
        pr_list = _gh(["pr", "list", "--author", "@me", "--limit", "1", "--json", GH_PR_JSON_FIELDS])
        pr_list = json.loads(pr_list)

        if len(pr_list) == 0:
            raise RuntimeError("Failed to find PR, are you sure you have any open PRs?")

        pr_data = pr_list[0]

    elif current_branch:
        pr_data = _gh(["pr", "view", "--json", GH_PR_JSON_FIELDS])
        pr_data = json.loads(pr_data)

    return pr_data


def format_message(pr_data: dict[str, any]) -> str:
    additions = pr_data["additions"]
    deletions = pr_data["deletions"]

    title = pr_data["title"]
    pr_url = pr_data["url"]
    pr_state = pr_data["state"]

    state_html = f"({pr_state.lower()}) " if pr_state != "OPEN" else ""
    additions_html = f"+{additions}" if additions > 0 else str(additions)
    deletions_html = f"-{deletions}" if deletions > 0 else str(deletions)

    return f"""{state_html}{pr_url} {title} [diff: {additions_html}/{deletions_html}]"""


def copy_to_clipboard(message: str):
    r = tkinter.Tk()
    r.withdraw()
    r.clipboard_clear()
    r.clipboard_append(message)
    r.update()
    r.destroy()


def main():
    args = parse_args()

    ensure_gh_installed()
    ensure_gh_authenticated()

    pr_data = fetch_pr_data(args.current_branch, args.latest, args.pr_id)
    message = format_message(pr_data)

    print("Message:\n")
    print(f"    {message}\n")

    if not args.no_clipboard:
        copy_to_clipboard(message)
        print("Copied to clipboard")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}")
        exit(1)

