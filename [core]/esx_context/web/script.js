const container = document.getElementById("container");

const createElement = (tag = "div", className = "", parent) => {
  const e = document.createElement(tag);
  e.className = className;
  parent?.append(e);
  return e;
};

const createInputElement = (type, parent) => {
  const input = createElement("input", "", parent);
  input.type = type;
  return input;
};

const open = (eles, position = "right") => {
  container.innerHTML = "";
  container.className = position;

  eles.forEach((ele, i) => {
    const item = createElement("div", "item", container);
    createElement("i", ele.icon, item);
    const div = createElement("div", "", item);
    const title = createElement("b", "", div);
    title.innerHTML = ele.title;

    if (ele.description) {
      const desc = createElement("i", "", div);
      desc.innerHTML = ele.description;
    }

    if (ele.input) {
      if (ele.inputType === "radio") {
        ele.inputValues.forEach((v) => {
          const container = createElement("label", "container", div);
          container.innerHTML = v.text;

          const input = createInputElement("radio", container);
          input.name = i + 1;
          input.checked = (ele.inputValue || ele.inputPlaceholder || -1) === v.value;
          createElement("span", "checkmark", container);

          input.onchange = () => {
            $.post(`https://${GetParentResourceName()}/changed`, JSON.stringify({ index: i + 1, value: v.value }));
          };
        });
      } else {
        const input = createInputElement(ele.inputType, div);

        if (ele.inputValue) input.value = ele.inputValue;
        if (ele.inputPlaceholder) input.placeholder = ele.inputPlaceholder;

        switch (ele.inputType) {
          case "number":
            input.min = ele.inputMin;
            input.max = ele.inputMax;

            input.onchange = () => {
              const v = Math.max(ele.inputMin || -Infinity, Math.min(ele.inputMax || Infinity, Number(input.value)));
              input.value = v;
              $.post(`https://${GetParentResourceName()}/changed`, JSON.stringify({ index: i + 1, value: v }));
            };
            break;
          case "text":
            input.onchange = () => {
              $.post(`https://${GetParentResourceName()}/changed`, JSON.stringify({ index: i + 1, value: input.value }));
            };
            break;
        }
      }
    } else {
      if (ele.disabled) {
        item.classList.add("disabled");
      } else if (ele.unselectable) {
        item.classList.add("unselectable");
      } else if (!ele.input) {
        item.onclick = () => {
          $.post(`https://${GetParentResourceName()}/selected`, JSON.stringify({ index: i + 1 }));
        };
      }
    }
  });

  document.body.style.display = "block";
};

const closed = () => {
  document.body.style.display = "none";
};

const close = () => {
  $.post(`https://${GetParentResourceName()}/closed`, (retVal) => {
    if (retVal) {
      closed();
    }
  });
};

window.addEventListener("message", (e) => {
  const data = e.data;
  const func = window[data.func];
  if (func) {
    func(...data.args);
  }
});

window.addEventListener("keydown", (e) => {
  if ((e.key === "Escape" || e.key === "Backspace") && e.target.tagName.toLowerCase() !== "input") {
    close();
    }
});