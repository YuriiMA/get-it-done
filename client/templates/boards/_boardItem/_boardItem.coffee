Template._boardItem.onCreated (->
	@.taskCreating = new ReactiveVar(false);
	@.bgColor = new ReactiveVar();
)


Template._boardItem.onRendered (->
#	instance = @
#	instance.bgColor.set instance.data.config.bgColor
#	@.$('.color-picker').colorpicker()
#		.on 'changeColor.colorpicker', (event) ->
#			instance.bgColor.set event.color.toHex()
#		.on 'showPicker.colorpicker', (event) ->
#			@.setColor instance.bgColor.get()
#		.on 'hidePicker.colorpicker', (event) ->
#			boardId = Blaze.getData(event.target)._id
#			Boards.update { _id: boardId }, { $set: 'config.bgColor': event.color.toHex()}, (err, res) ->
#				console.log err or res

	@.$('.tile__list').sortable
		connectWith: '.tile__list'
		helper: 'clone'
		items: '.action'
		forcePlaceholderSize: !0
		dropOnEmpty: true
		opacity: 0.8
		zIndex: 9999
		update: (event, ui) ->
			targetBoardId = Blaze.getData(event.target)._id
			targetTaskId = Blaze.getData(ui.item[0])._id
			try
				prevTaskData = Blaze.getData ui.item[0].previousElementSibling
			try
				nextTaskData = Blaze.getData ui.item[0].nextElementSibling
			if !nextTaskData and prevTaskData
				curOrder = prevTaskData.order + 1
			if !prevTaskData and nextTaskData
				curOrder = nextTaskData.order/2
			if !prevTaskData and !nextTaskData
				curOrder = 1
			if prevTaskData and nextTaskData
				curOrder = (nextTaskData.order + prevTaskData.order) / 2
			Tasks.update { _id: targetTaskId }, { $set: boardId: targetBoardId, order: curOrder}, (err, res) ->
				console.log err or res
)

Template._boardItem.helpers
	tasks: () ->
		return Tasks.find { boardId: Template.instance().data._id }, {sort: {order: 1} }
	taskCreating: () ->
		return Template.instance().taskCreating and Template.instance().taskCreating.get()
	bgColor: () ->
		console.log 'bgColor', Template.instance().bgColor.get()
		return Template.instance().bgColor.get()

Template._boardItem.events
	'click .new-task-action': (e, t) ->
		Template.instance().taskCreating.set true
	'click .complete-action': (e, t) ->
		taskData = Blaze.getData(event.target)
		Tasks.update { _id: taskData._id }, { $set: completed: !taskData.completed }, (err, res) ->
  		console.log err or res
	'click .ok-action': (e, t) ->
		text = $(e.target).parent().parent().find('textarea').val()
		if !text or !text.length
			alert 'text is required'
		else
			boardId = t.data._id
			Tasks.insert {ownerId: Meteor.userId(), boardId: boardId, text: text, completed: false}, (err, res) ->
				console.log err or res
		Template.instance().taskCreating.set false
	'click .cancel-action': (e, t) ->
		Template.instance().taskCreating.set false
	'change .color-picker': (e, t) ->
		instance = Template.instance()
		instance.bgColor.set e.target.value
		console.log instance.bgColor.get()
		boardId = Blaze.getData(e.target)._id
		Boards.update { _id: boardId }, { $set: 'config.bgColor': e.target.value}, (err, res) ->
			console.log err or res

