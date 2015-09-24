const dialogStore = {};

module.exports = {
  get (dialogId) {
    return dialogStore[dialogId];
  },

  set (dialogId, dialog) {
    dialogStore[dialogId] = dialog;
  }
};
