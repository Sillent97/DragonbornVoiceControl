from dataclasses import dataclass, field
from typing import Dict, Iterable

FEATURE_ORDER: tuple[str, ...] = (
    "select",
    "open",
    "close",
    "shouts",
    "powers",
    "weapons",
    "spells",
    "potions",
)


def situation_allowed(*, dialog_open: bool, focus_on: bool) -> Dict[str, bool]:
    # Focus is reserved for future rules; it does not affect the current matrix.
    _ = focus_on
    if dialog_open:
        return {
            "select": True,
            "open": False,
            "close": True,
            "shouts": False,
            "powers": False,
            "weapons": False,
            "spells": False,
            "potions": False,
        }

    return {
        "select": False,
        "open": False,
        "close": False,
        "shouts": True,
        "powers": True,
        "weapons": True,
        "spells": True,
        "potions": True,
    }


def compute_effective(
    *,
    feature_enabled: Dict[str, bool],
    dialog_open: bool,
    focus_on: bool,
) -> Dict[str, bool]:
    allowed = situation_allowed(dialog_open=dialog_open, focus_on=focus_on)
    return {
        key: bool(feature_enabled.get(key, False) and allowed.get(key, False))
        for key in FEATURE_ORDER
    }


def format_state(prefix: str, state: Dict[str, bool]) -> str:
    parts = [f"{key}={'ON' if state.get(key, False) else 'OFF'}" for key in FEATURE_ORDER]
    return f"{prefix}: " + " ".join(parts)


@dataclass
class VoiceState:
    feature_enabled: Dict[str, bool] = field(default_factory=dict)
    dialog_open: bool = False
    focus_on: bool = False
    last_effective: Dict[str, bool] | None = None

    def set_feature_enabled(self, enabled: Dict[str, bool]) -> None:
        self.feature_enabled = dict(enabled)

    def set_dialog_open(self, dialog_open: bool) -> None:
        self.dialog_open = bool(dialog_open)

    def set_focus_on(self, focus_on: bool) -> None:
        self.focus_on = bool(focus_on)

    def effective(self) -> Dict[str, bool]:
        return compute_effective(
            feature_enabled=self.feature_enabled,
            dialog_open=self.dialog_open,
            focus_on=self.focus_on,
        )

    def effective_changed(self) -> tuple[bool, Dict[str, bool]]:
        current = self.effective()
        changed = current != self.last_effective
        if changed:
            self.last_effective = current
        return changed, current

    def format_effective(self, effective: Dict[str, bool] | None = None) -> str:
        return format_state("effective", effective or self.effective())

    def format_listen_status(self, effective: Dict[str, bool] | None = None) -> str:
        return format_state("[LISTEN][STATE] Listen status", effective or self.effective())
